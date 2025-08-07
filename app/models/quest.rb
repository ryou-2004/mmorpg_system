class Quest < ApplicationRecord
  has_many :character_quests, dependent: :destroy
  has_many :characters, through: :character_quests
  belongs_to :prerequisite_quest, class_name: "Quest", optional: true
  has_many :dependent_quests, class_name: "Quest", foreign_key: "prerequisite_quest_id"
  belongs_to :quest_category, optional: true
  has_many :npc_quests, dependent: :destroy
  has_many :npcs, through: :npc_quests

  validates :title, presence: true, length: { maximum: 255 }
  validates :quest_type, presence: true, inclusion: { in: %w[main_story sub_story super_helpful helpful craftsman job random] }
  validates :display_number, uniqueness: { scope: :quest_type }, allow_nil: true
  validates :level_requirement, presence: true, numericality: { greater_than: 0, less_than_or_equal: 100 }
  validates :experience_reward, presence: true, numericality: { greater_than_or_equal: 0 }
  validates :gold_reward, presence: true, numericality: { greater_than_or_equal: 0 }
  validates :skill_point_reward, presence: true, numericality: { greater_than_or_equal: 0 }
  validates :status, presence: true, inclusion: { in: %w[available unavailable maintenance] }
  validates :display_order, presence: true, numericality: { greater_than_or_equal: 0 }

  scope :active, -> { where(active: true) }
  scope :available, -> { where(status: "available") }
  scope :by_type, ->(type) { where(quest_type: type) }
  scope :by_level, ->(level) { where("level_requirement <= ?", level) }
  scope :ordered, -> { order(:display_order, :id) }

  def quest_type_name
    case quest_type
    when "main_story" then "メインストーリー"
    when "sub_story" then "サブストーリー"
    when "super_helpful" then "超お役立ち機能"
    when "helpful" then "お役立ち機能"
    when "craftsman" then "職人クエスト"
    when "job" then "職業クエスト"
    when "random" then "ランダム"
    else quest_type
    end
  end

  def status_name
    case status
    when "available" then "利用可能"
    when "unavailable" then "利用不可"
    when "maintenance" then "メンテナンス中"
    else status
    end
  end

  def total_rewards
    rewards = {
      experience: experience_reward,
      gold: gold_reward,
      skill_points: skill_point_reward
    }

    if item_rewards.present?
      rewards[:items] = item_rewards.map do |item|
        {
          type: item["type"],
          item_id: item["item_id"],
          quantity: item["quantity"],
          name: get_item_name(item["type"], item["item_id"])
        }
      end
    end

    rewards
  end

  def display_title
    if display_number && quest_type != "random"
      "#{quest_type_name}#{display_number}・#{title}"
    else
      title
    end
  end

  def has_display_number?
    quest_type != "random"
  end

  def add_item_reward(type, item_id, quantity)
    current_rewards = item_rewards || []
    current_rewards << {
      "type" => type,
      "item_id" => item_id,
      "quantity" => quantity
    }
    update!(item_rewards: current_rewards)
  end

  def remove_item_reward(index)
    current_rewards = item_rewards || []
    current_rewards.delete_at(index) if index < current_rewards.length
    update!(item_rewards: current_rewards)
  end

  private

  def get_item_name(type, item_id)
    case type
    when "Item"
      Item.find_by(id: item_id)&.name || "アイテム(ID: #{item_id})"
    else
      "#{type}(ID: #{item_id})"
    end
  rescue
    "#{type}(ID: #{item_id})"
  end
end
