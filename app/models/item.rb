class Item < ApplicationRecord
  has_many :character_items, dependent: :destroy
  has_many :characters, through: :character_items

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
    bazaar: "bazaar",       # バザー（キャラクター間取引）で売却可能
    both: "both",           # ショップとバザー両方で売却可能
    unsellable: "unsellable" # 売却不可（クエストアイテムなど）
  }

  # 装備スロット定数
  EQUIPMENT_SLOTS = %w[右手 左手 頭 胴 腰 腕 足 指輪 首飾り].freeze

  validates :name, presence: true, length: { maximum: 100 }
  validates :item_type, presence: true
  validates :rarity, presence: true
  validates :max_stack, presence: true, numericality: { greater_than: 0 }
  validates :buy_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sell_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :level_requirement, presence: true, numericality: { greater_than: 0 }
  validates :equipment_slot, inclusion: { 
    in: EQUIPMENT_SLOTS, 
    allow_nil: true,
    message: "は有効な装備スロットではありません" 
  }

  # STI関連のバリデーション
  validates :weapon_category, presence: true, if: :weapon?
  validates :weapon_category, absence: true, unless: :weapon?
  validates :armor_category, presence: true, if: :armor?
  validates :armor_category, absence: true, unless: :armor?
  validates :accessory_category, presence: true, if: :accessory?
  validates :accessory_category, absence: true, unless: :accessory?

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

  def weapon?
    item_type == "weapon"
  end

  def armor?
    item_type == "armor"
  end

  def accessory?
    item_type == "accessory"
  end

  def material?
    item_type == "material"
  end

  def quest_item?
    item_type == "quest"
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

  # STI用のtype更新メソッド
  def update_sti_type!
    new_type = case item_type
               when 'weapon' then 'Weapon'
               when 'armor' then 'Armor'
               when 'accessory' then 'Accessory'
               when 'consumable' then 'Consumable'
               when 'material' then 'Material'
               when 'quest' then 'QuestItem'
               else 'Item'
               end
    update_column(:type, new_type) if type != new_type
  end
end
