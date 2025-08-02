class CharacterItem < ApplicationRecord
  belongs_to :character
  belongs_to :item
  belongs_to :character_warehouse, optional: true
  belongs_to :bazaar_listing, optional: true

  enum :location, {
    inventory: "inventory",
    warehouse: "warehouse",
    equipped: "equipped"
  }, default: "inventory"

  enum :status, {
    available: "available",        # 利用可能（デフォルト）
    admin_locked: "admin_locked",  # 管理者による利用停止
    bazaar_listed: "bazaar_listed",
    mail_attached: "mail_attached"
  }, default: "available"

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :enchantment_level, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :locked, inclusion: { in: [ true, false ] }
  
  # 装備スロット定義
  EQUIPMENT_SLOTS = {
    "weapon" => "武器",
    "armor" => "防具", 
    "accessory_1" => "アクセサリー1",
    "accessory_2" => "アクセサリー2"
  }.freeze
  
  validates :equipment_slot, inclusion: { in: EQUIPMENT_SLOTS.keys }, allow_nil: true
  validates :equipment_slot, presence: true, if: :equipped?
  validates :equipment_slot, uniqueness: { scope: :character_id }, if: :equipped?

  # === 状態判定メソッド ===
  def character_accessible?
    available?
  end

  def can_move?
    available? && !locked? && !equipped?
  end

  def can_equip?
    available? && !locked? && item.equipment? && (inventory? || warehouse?)
  end
  
  def can_equip_to_slot?(slot)
    return false unless can_equip?
    return false unless EQUIPMENT_SLOTS.key?(slot)
    
    # アイテムタイプと装備スロットの対応チェック
    case slot
    when "weapon"
      item.weapon?
    when "armor" 
      item.armor?
    when "accessory_1", "accessory_2"
      item.accessory?
    else
      false
    end
  end

  def can_use?
    available? && !locked? && item.consumable? && (inventory? || warehouse?)
  end

  def can_sell_to_bazaar?
    available? && !locked? && !equipped? && item.sellable?
  end

  def can_delete?
    available? && !locked? && !equipped?
  end

  def in_circulation?
    bazaar_listed? || mail_attached?
  end

  # === キャラクター保護ロック機能 ===
  def toggle_lock!
    return false unless available?
    update!(locked: !locked?)
  end

  # === 表示用メソッド ===
  def display_status
    return "⛔ 利用停止" if admin_locked?

    status_text = case status
    when "bazaar_listed" then "🏪 出品中"
    when "mail_attached" then "📧 送信中"
    else nil
    end

    lock_text = locked? ? "🔒 保護中" : nil

    [ status_text, lock_text ].compact.join(" ")
  end

  def status_color
    return "red" if admin_locked?
    return "yellow" if locked?

    case status
    when "bazaar_listed" then "blue"
    when "mail_attached" then "green"
    else "gray"
    end
  end

  # === スコープ ===
  scope :character_accessible, -> { where(status: "available") }
  scope :actionable_items, -> { character_accessible.where(locked: false) }
  scope :locked_items, -> { where(locked: true) }
  scope :admin_locked_items, -> { where(status: "admin_locked") }
  scope :inventory_items, -> { where(location: "inventory") }
  scope :warehouse_items, -> { where(location: "warehouse") }
  scope :equipped_items, -> { where(location: "equipped") }
  scope :by_item_type, ->(type) { joins(:item).where(items: { item_type: type }) }
  scope :by_equipment_slot, ->(slot) { where(equipment_slot: slot) }
  scope :equipped_in_slot, ->(slot) { equipped_items.by_equipment_slot(slot) }

  # === 既存メソッド（互換性のため保持） ===
  def equipped?
    location == "equipped"
  end

  def can_stack_with?(other_character_item)
    return false unless item == other_character_item.item
    return false unless item.stackable?
    return false if equipped? || other_character_item.equipped?
    return false unless available? && other_character_item.available?

    enchantment_level == other_character_item.enchantment_level
  end

  def total_quantity_available
    return quantity unless item.stackable?

    character.character_items
          .where(item: item, enchantment_level: enchantment_level)
          .where.not(location: "equipped")
          .actionable_items
          .sum(:quantity)
  end

  def durability_percentage
    return 100 if max_durability.nil? || max_durability.zero?
    return 0 if durability.nil? || durability.zero?

    (durability.to_f / max_durability * 100).round
  end

  # === アイテム移動・使用メソッド ===
  def move_to_inventory!
    raise "アイテムを移動できません" unless can_move?
    raise "既にインベントリにあります" if inventory?
    
    transaction do
      update!(
        location: "inventory",
        character_warehouse: nil,
        equipment_slot: nil
      )
    end
  end

  def move_to_warehouse!(warehouse)
    raise "アイテムを移動できません" unless can_move?
    raise "倉庫が見つかりません" unless warehouse
    raise "キャラクターの倉庫ではありません" unless warehouse.character == character
    raise "倉庫の容量が不足しています" unless warehouse.has_available_slots?
    
    transaction do
      update!(
        location: "warehouse",
        character_warehouse: warehouse,
        equipment_slot: nil
      )
    end
  end

  def equip_to_slot!(slot)
    raise "装備できません" unless can_equip_to_slot?(slot)
    
    # 既存の装備を外す
    existing_equipment = character.character_items.equipped_in_slot(slot).first
    existing_equipment&.unequip!
    
    transaction do
      update!(
        location: "equipped",
        equipment_slot: slot
      )
    end
  end

  def unequip!
    raise "装備を外せません" unless equipped?
    
    transaction do
      update!(
        location: "inventory",
        equipment_slot: nil
      )
    end
  end

  def use_item!
    raise "アイテムを使用できません" unless can_use?
    raise "消耗品ではありません" unless item.consumable?
    
    effects = apply_item_effects!
    
    transaction do
      if quantity > 1
        update!(quantity: quantity - 1)
      else
        destroy!
      end
    end
    
    {
      message: "#{item.name}を使用しました",
      effects: effects
    }
  end

  private

  def apply_item_effects!
    effects_applied = []
    return effects_applied unless item.effects.is_a?(Array)
    
    item.effects.each do |effect|
      next unless effect.is_a?(Hash)
      
      case effect["type"]
      when "heal"
        apply_heal_effect(effect)
        effects_applied << "HP回復: #{effect['amount']}"
      when "mp_heal"
        apply_mp_heal_effect(effect)
        effects_applied << "MP回復: #{effect['amount']}"
      when "status"
        apply_status_effect(effect)
        effects_applied << "ステータス効果: #{effect['name']}"
      end
    end
    
    effects_applied
  end

  def apply_heal_effect(effect)
    # 実際のHP回復処理はキャラクターの現在ステータスと連携
    # ここでは効果のみ記録
    Rails.logger.info "HP回復効果: #{effect['amount']}"
  end

  def apply_mp_heal_effect(effect)
    # 実際のMP回復処理はキャラクターの現在ステータスと連携
    Rails.logger.info "MP回復効果: #{effect['amount']}"
  end

  def apply_status_effect(effect)
    # ステータス効果の処理
    Rails.logger.info "ステータス効果: #{effect['name']}"
  end
end
