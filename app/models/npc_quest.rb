class NpcQuest < ApplicationRecord
  belongs_to :npc
  belongs_to :quest

  validates :npc_id, uniqueness: { scope: :quest_id }
  validates :relationship_type, presence: true, inclusion: { in: %w[giver receiver related] }

  scope :givers, -> { where(relationship_type: "giver") }
  scope :receivers, -> { where(relationship_type: "receiver") }
  scope :related, -> { where(relationship_type: "related") }

  def relationship_type_name
    case relationship_type
    when "giver" then "依頼者"
    when "receiver" then "報告先"
    when "related" then "関連NPC"
    else relationship_type
    end
  end
end
