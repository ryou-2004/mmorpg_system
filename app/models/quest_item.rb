class QuestItem < Item
  validates :equipment_slot, absence: { message: "クエストアイテムは装備できません" }
  validates :sale_type, inclusion: {
    in: [ "unsellable" ],
    message: "クエストアイテムは売却不可である必要があります"
  }

  scope :active_quest, -> { where(active: true) }
  scope :completed_quest, -> { where(active: false) }

  def stackable?
    max_stack > 1
  end

  def equipment?
    false
  end

  def sellable?
    false
  end

  def quest_related?
    true
  end

  def important?
    rarity.in?([ "epic", "legendary" ])
  end

  def can_discard?
    # クエスト進行状況によって判定（実装予定）
    false
  end

  def related_quest_id
    # クエストIDを取得（実装予定）
    nil
  end
end
