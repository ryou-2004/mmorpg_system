class Character < ApplicationRecord
  belongs_to :user
  has_many :character_job_classes, dependent: :destroy
  has_many :job_classes, through: :character_job_classes
  has_many :character_items, dependent: :destroy
  has_many :items, through: :character_items
  has_many :character_warehouses, dependent: :destroy
  has_many :character_skills, dependent: :destroy
  has_many :battle_participants, dependent: :destroy
  has_many :battles, through: :battle_participants
  has_many :won_battles, class_name: 'Battle', foreign_key: 'winner_id'
  has_many :attacker_logs, class_name: 'BattleLog', foreign_key: 'attacker_id'
  has_many :defender_logs, class_name: 'BattleLog', foreign_key: 'defender_id'
  belongs_to :current_character_job_class, class_name: "CharacterJobClass", optional: true

  attr_accessor :skip_job_validation

  validates :name, presence: true, length: { minimum: 2, maximum: 20 }
  validates :name, uniqueness: { scope: :user_id }
  validates :gold, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :current_character_job_class, presence: true, unless: :skip_job_validation

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  after_create :create_default_warehouse

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end

  def update_last_login!
    update!(last_login_at: Time.current)
  end

  def add_gold!(amount)
    update!(gold: gold + amount)
  end

  def spend_gold!(amount)
    return false if gold < amount
    update!(gold: gold - amount)
    true
  end

  def unlock_job!(job_class)
    character_job_class = character_job_classes.find_or_create_by!(job_class: job_class) do |cjc|
      cjc.unlocked_at = Time.current
    end
    
    # If this is the first job, set it as current
    if current_character_job_class.nil?
      update!(current_character_job_class: character_job_class)
    end
    
    character_job_class
  end

  # 現在の職業への委譲メソッド
  delegate :level, :experience, :skill_points, :hp, :max_hp, :mp, :max_mp,
           :attack, :defense, :magic_attack, :magic_defense, :agility, :luck,
           :gain_experience, :can_level_up?, :level_up!, :exp_to_next_level,
           :level_progress, :max_level?, to: :current_character_job_class, allow_nil: true

  # 職業切り替えメソッド
  def switch_job!(job_class)
    target_character_job_class = character_job_classes.find_by(job_class: job_class)
    raise "Job class not unlocked: #{job_class.name}" unless target_character_job_class

    update!(current_character_job_class: target_character_job_class)
    current_character_job_class
  end

  def current_job_name
    current_character_job_class&.job_class&.name
  end

  def job_unlocked?(job_class)
    character_job_classes.exists?(job_class: job_class)
  end

  # === インベントリ・倉庫関連メソッド ===
  def inventory_items
    character_items.inventory_items.character_accessible
  end

  def warehouse_items(warehouse = nil)
    items = character_items.warehouse_items.character_accessible
    warehouse ? items.where(character_warehouse: warehouse) : items
  end

  def equipped_items
    character_items.equipped_items.character_accessible
  end
  
  # 装備スロット別アイテム取得
  def equipment_in_slot(slot)
    character_items.equipped_in_slot(slot).character_accessible.first
  end
  
  # アイテム装備
  def equip_item!(character_item, slot)
    return false unless character_item.can_equip_to_slot?(slot)
    return false unless character_item.character == self
    
    transaction do
      # 既存の装備を解除
      current_equipment = equipment_in_slot(slot)
      if current_equipment
        current_equipment.update!(
          location: "inventory",
          equipment_slot: nil
        )
      end
      
      # 新しいアイテムを装備
      character_item.update!(
        location: "equipped",
        equipment_slot: slot
      )
    end
    
    true
  rescue => e
    Rails.logger.error "Failed to equip item: #{e.message}"
    false
  end
  
  # アイテム解除
  def unequip_item!(character_item)
    return false unless character_item.equipped?
    return false unless character_item.character == self
    
    character_item.update!(
      location: "inventory",
      equipment_slot: nil
    )
    
    true
  rescue => e
    Rails.logger.error "Failed to unequip item: #{e.message}"
    false
  end

  def main_warehouse
    character_warehouses.first
  end

  # === パフォーマンス最適化されたカウントメソッド ===
  def item_counts_by_location
    @item_counts_by_location ||= character_items.character_accessible
                                                .group(:location, :character_warehouse_id)
                                                .count
  end

  def inventory_count
    item_counts_by_location.select { |key, _| key[0] == "inventory" }.sum(&:last)
  end

  def equipped_count
    item_counts_by_location.select { |key, _| key[0] == "equipped" }.sum(&:last)
  end

  def warehouse_usage_by_id
    item_counts_by_location.select { |key, _| key[0] == "warehouse" }
                           .transform_keys { |key| key[1] } # warehouse_idをキーにする
  end

  private

  def create_default_warehouse
    character_warehouses.create!(name: I18n.t('warehouses.main'), max_slots: 100)
  end
end
