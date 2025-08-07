class Npc < ApplicationRecord
  has_many :npc_shops, dependent: :destroy
  has_many :shops, through: :npc_shops
  has_many :npc_quests, dependent: :destroy
  has_many :quests, through: :npc_quests
  has_many :character_npc_interactions, dependent: :destroy
  has_many :interacted_characters, through: :character_npc_interactions, source: :character
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :npc_type, presence: true, inclusion: { in: %w[villager merchant quest_giver trainer guard boss special] }

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(npc_type: type) }
  scope :by_location, ->(location) { where(location: location) }
  scope :with_dialogue, -> { where(has_dialogue: true) }
  scope :with_shop, -> { where(has_shop: true) }
  scope :with_quests, -> { where(has_quests: true) }
  scope :with_training, -> { where(has_training: true) }
  scope :with_battle, -> { where(has_battle: true) }

  def available_functions
    functions = []
    functions << :dialogue if has_dialogue?
    functions << :shop if has_shop?
    functions << :quests if has_quests?
    functions << :training if has_training?
    functions << :battle if has_battle?
    functions
  end

  def primary_role
    return :dialogue_only if has_dialogue? && !has_shop? && !has_quests? && !has_training? && !has_battle?
    return :merchant if has_shop? && !has_quests?
    return :quest_giver if has_quests? && !has_shop?
    return :trainer if has_training?
    return :guard if has_battle?
    return :multi_function if available_functions.size > 1
    :unknown
  end

  def role_name
    case primary_role
    when :dialogue_only then "会話のみ"
    when :merchant then "商人"
    when :quest_giver then "クエスト依頼者"
    when :trainer then "訓練師"
    when :guard then "戦闘NPC"
    when :multi_function then "複合機能"
    else "不明"
    end
  end

  def npc_type_name
    case npc_type
    when "villager" then "村人"
    when "merchant" then "商人"
    when "quest_giver" then "クエスト依頼者"
    when "trainer" then "訓練師"
    when "guard" then "衛兵"
    when "boss" then "ボス"
    when "special" then "特殊NPC"
    else npc_type
    end
  end

  def function_summary
    functions = available_functions
    return "機能なし" if functions.empty?

    function_names = {
      dialogue: "会話",
      shop: "ショップ",
      quests: "クエスト",
      training: "訓練",
      battle: "戦闘"
    }

    functions.map { |f| function_names[f] }.join("・")
  end
end
