class CharacterNpcInteraction < ApplicationRecord
  belongs_to :character
  belongs_to :npc

  validates :character_id, uniqueness: { scope: :npc_id }
  validates :interaction_type, presence: true, inclusion: { in: %w[dialogue shop quest training battle] }

  scope :by_type, ->(type) { where(interaction_type: type) }
  scope :recent, -> { order(last_interaction_at: :desc) }

  def interaction_type_name
    case interaction_type
    when "dialogue" then "会話"
    when "shop" then "ショップ利用"
    when "quest" then "クエスト関連"
    when "training" then "訓練"
    when "battle" then "戦闘"
    else interaction_type
    end
  end

  def update_interaction!(type, data = {})
    update!(
      interaction_type: type,
      metadata: metadata.merge(data),
      last_interaction_at: Time.current
    )
  end

  def interaction_count
    metadata["count"] || 0
  end

  def increment_interaction_count!
    current_count = interaction_count
    update_interaction!(interaction_type, { count: current_count + 1 })
  end
end
