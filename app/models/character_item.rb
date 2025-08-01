class PlayerItem < ApplicationRecord
  belongs_to :player
  belongs_to :item
  belongs_to :player_warehouse, optional: true
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

  # === 状態判定メソッド ===
  def player_accessible?
    available?
  end

  def can_move?
    available? && !locked? && !equipped?
  end

  def can_equip?
    available? && !locked? && item.equipment? && (inventory? || warehouse?)
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

  # === プレイヤー保護ロック機能 ===
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
  scope :player_accessible, -> { where(status: "available") }
  scope :actionable_items, -> { player_accessible.where(locked: false) }
  scope :locked_items, -> { where(locked: true) }
  scope :admin_locked_items, -> { where(status: "admin_locked") }
  scope :inventory_items, -> { where(location: "inventory") }
  scope :warehouse_items, -> { where(location: "warehouse") }
  scope :equipped_items, -> { where(location: "equipped") }
  scope :by_item_type, ->(type) { joins(:item).where(items: { item_type: type }) }

  # === 既存メソッド（互換性のため保持） ===
  def equipped?
    location == "equipped"
  end

  def can_stack_with?(other_player_item)
    return false unless item == other_player_item.item
    return false unless item.stackable?
    return false if equipped? || other_player_item.equipped?
    return false unless available? && other_player_item.available?

    enchantment_level == other_player_item.enchantment_level
  end

  def total_quantity_available
    return quantity unless item.stackable?

    player.player_items
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
end
