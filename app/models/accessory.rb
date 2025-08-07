class Accessory < Item
  enum :accessory_category, {
    ring: "ring",           # 指輪
    necklace: "necklace",   # 首飾り
    brooch: "brooch",       # ブローチ
    earring: "earring"      # イヤリング
  }, validate: true

  validates :accessory_category, presence: true
  validates :equipment_slot, inclusion: {
    in: %w[指輪 首飾り],
    message: "は指輪または首飾りである必要があります"
  }

  scope :rings, -> { where(accessory_category: "ring") }
  scope :necklaces, -> { where(accessory_category: "necklace") }
  scope :brooches, -> { where(accessory_category: "brooch") }
  scope :earrings, -> { where(accessory_category: "earring") }

  def accessory_category_name
    case accessory_category
    when "ring" then "指輪"
    when "necklace" then "首飾り"
    when "brooch" then "ブローチ"
    when "earring" then "イヤリング"
    else accessory_category
    end
  end

  def ring?
    accessory_category == "ring"
  end

  def necklace?
    accessory_category == "necklace"
  end

  def brooch?
    accessory_category == "brooch"
  end

  def earring?
    accessory_category == "earring"
  end

  def slot_name
    case accessory_category
    when "ring" then "指輪"
    when "necklace" then "首飾り"
    when "brooch" then "胴"
    when "earring" then "頭"
    else equipment_slot
    end
  end
end
