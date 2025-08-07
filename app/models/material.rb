class Material < Item
  validates :equipment_slot, absence: { message: "素材は装備できません" }

  scope :crafting, -> { where("description LIKE ?", "%作成%") }
  scope :enhancement, -> { where("description LIKE ?", "%強化%") }
  scope :rare, -> { where(rarity: [ "rare", "epic", "legendary" ]) }

  def stackable?
    max_stack > 1
  end

  def equipment?
    false
  end

  def for_crafting?
    description.to_s.include?("作成")
  end

  def for_enhancement?
    description.to_s.include?("強化")
  end

  def crafting_material?
    for_crafting?
  end

  def enhancement_material?
    for_enhancement?
  end

  def rarity_value
    case rarity
    when "common" then 1
    when "uncommon" then 2
    when "rare" then 3
    when "epic" then 4
    when "legendary" then 5
    else 0
    end
  end
end
