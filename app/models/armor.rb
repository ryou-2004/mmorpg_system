class Armor < Item
  enum :armor_category, {
    head: "head",       # 頭
    body: "body",       # 胴
    waist: "waist",     # 腰
    arm: "arm",         # 腕
    leg: "leg",         # 足
    shield: "shield"    # 盾
  }, validate: true

  validates :armor_category, presence: true

  scope :shields, -> { where(armor_category: "shield") }
  scope :head_armor, -> { where(armor_category: "head") }
  scope :body_armor, -> { where(armor_category: "body") }
  scope :waist_armor, -> { where(armor_category: "waist") }
  scope :arm_armor, -> { where(armor_category: "arm") }
  scope :leg_armor, -> { where(armor_category: "leg") }

  def armor_category_name
    I18n.t("armors.categories.#{armor_category}", default: armor_category)
  end

  def is_shield?
    armor_category == "shield"
  end


  def equipment_slot
    case armor_category
    when "head" then I18n.t("equipment_slots.head")
    when "body" then I18n.t("equipment_slots.body")
    when "waist" then I18n.t("equipment_slots.waist")
    when "arm" then I18n.t("equipment_slots.arm")
    when "leg" then I18n.t("equipment_slots.leg")
    when "shield" then I18n.t("equipment_slots.left_hand")
    else armor_category
    end
  end
end
