class Item < ApplicationRecord
  has_many :player_items, dependent: :destroy
  has_many :players, through: :player_items

  enum :item_type, {
    weapon: "weapon",
    armor: "armor",
    accessory: "accessory",
    consumable: "consumable",
    material: "material",
    quest: "quest"
  }

  enum :rarity, {
    common: "common",       # コモン (白)
    uncommon: "uncommon",   # アンコモン (緑)
    rare: "rare",           # レア (青)
    epic: "epic",           # エピック (紫)
    legendary: "legendary"  # レジェンダリー (橙)
  }

  enum :sale_type, {
    shop: "shop",           # ショップで売却可能
    bazaar: "bazaar",       # バザー（プレイヤー間取引）で売却可能
    both: "both",           # ショップとバザー両方で売却可能
    unsellable: "unsellable" # 売却不可（クエストアイテムなど）
  }

  validates :name, presence: true, length: { maximum: 100 }
  validates :item_type, presence: true
  validates :rarity, presence: true
  validates :max_stack, presence: true, numericality: { greater_than: 0 }
  validates :buy_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sell_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :level_requirement, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(item_type: type) }
  scope :by_rarity, ->(rarity) { where(rarity: rarity) }

  def stackable?
    max_stack > 1
  end

  def equipment?
    %w[weapon armor accessory].include?(item_type)
  end

  def consumable?
    item_type == "consumable"
  end

  def rarity_color
    case rarity
    when "common" then "#ffffff"
    when "uncommon" then "#1eff00"
    when "rare" then "#0070dd"
    when "epic" then "#a335ee"
    when "legendary" then "#ff8000"
    end
  end

  def can_sell_to_shop?
    shop? || both?
  end

  def can_sell_to_bazaar?
    bazaar? || both?
  end

  def sellable?
    !unsellable?
  end

  def sale_type_description
    case sale_type
    when "shop" then "ショップ売却可"
    when "bazaar" then "バザー売却可"
    when "both" then "ショップ・バザー売却可"
    when "unsellable" then "売却不可"
    end
  end
end
