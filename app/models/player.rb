class Player < ApplicationRecord
  belongs_to :user
  has_many :player_job_classes, dependent: :destroy
  has_many :job_classes, through: :player_job_classes
  has_many :player_items, dependent: :destroy
  has_many :items, through: :player_items
  has_many :player_warehouses, dependent: :destroy
  belongs_to :current_job_class, class_name: "PlayerJobClass", optional: true

  validates :name, presence: true, length: { minimum: 2, maximum: 20 }
  validates :name, uniqueness: { scope: :user_id }
  validates :gold, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :current_job_class, presence: true

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
    player_job_classes.find_or_create_by!(job_class: job_class) do |pjc|
      pjc.unlocked_at = Time.current
    end
  end

  # 現在の職業への委譲メソッド
  delegate :level, :experience, :skill_points, :hp, :max_hp, :mp, :max_mp,
           :attack, :defense, :magic_attack, :magic_defense, :agility, :luck,
           :gain_experience, :can_level_up?, :level_up!, :exp_to_next_level,
           :level_progress, :max_level?, to: :current_job_class, allow_nil: true

  # 職業切り替えメソッド
  def switch_job!(job_class)
    target_player_job_class = player_job_classes.find_by(job_class: job_class)
    raise "Job class not unlocked: #{job_class.name}" unless target_player_job_class

    update!(current_job_class: target_player_job_class)
    current_job_class
  end

  def current_job_name
    current_job_class&.job_class&.name
  end

  def job_unlocked?(job_class)
    player_job_classes.exists?(job_class: job_class)
  end

  # === インベントリ・倉庫関連メソッド ===
  def inventory_items
    player_items.inventory_items.player_accessible
  end

  def warehouse_items(warehouse = nil)
    items = player_items.warehouse_items.player_accessible
    warehouse ? items.where(player_warehouse: warehouse) : items
  end

  def equipped_items
    player_items.equipped_items.player_accessible
  end

  def main_warehouse
    player_warehouses.first
  end

  private

  def create_default_warehouse
    player_warehouses.create!(name: "メイン倉庫", max_slots: 100)
  end
end
