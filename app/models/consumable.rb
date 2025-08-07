class Consumable < Item
  validates :max_stack, presence: true, numericality: { greater_than: 1 }
  validates :equipment_slot, absence: { message: "消耗品は装備できません" }

  scope :healing, -> { where("effects LIKE ?", "%heal%") }
  scope :buff, -> { where("effects LIKE ?", "%buff%") }
  scope :recovery, -> { where("effects LIKE ?", "%recovery%") }

  def stackable?
    true
  end

  def consumable?
    true
  end

  def equipment?
    false
  end

  def has_healing_effect?
    effects.to_s.include?("heal")
  end

  def has_buff_effect?
    effects.to_s.include?("buff")
  end

  def has_recovery_effect?
    effects.to_s.include?("recovery")
  end

  def effect_duration
    # JSON effectsから持続時間を取得（実装予定）
    nil
  end
end
