class Shop < ApplicationRecord
  has_many :shop_items, dependent: :destroy
  has_many :items, through: :shop_items

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :shop_type, presence: true, inclusion: { in: %w[general weapon armor potion material special] }
  validates :display_order, presence: true, numericality: { greater_than_or_equal: 0 }

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(shop_type: type) }
  scope :by_location, ->(location) { where(location: location) }
  scope :ordered, -> { order(:display_order, :id) }

  def shop_type_name
    case shop_type
    when "general" then "雑貨店"
    when "weapon" then "武器屋"
    when "armor" then "防具屋"
    when "potion" then "道具屋"
    when "material" then "素材屋"
    when "special" then "特殊ショップ"
    else shop_type
    end
  end

  def active_items_count
    shop_items.active.count
  end

  def total_items_value
    shop_items.active.sum(:buy_price)
  end

  def available_items
    shop_items.includes(:item).active.where(
      "unlimited_stock = ? OR stock_quantity > ?",
      true, 0
    ).order(:display_order)
  end

  def out_of_stock_items
    shop_items.includes(:item).active.where(
      unlimited_stock: false,
      stock_quantity: 0
    )
  end
end
