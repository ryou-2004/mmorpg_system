class ShopItem < ApplicationRecord
  belongs_to :shop
  belongs_to :item

  validates :shop_id, uniqueness: { scope: :item_id }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal: 0 }
  validates :display_order, presence: true, numericality: { greater_than_or_equal: 0 }

  scope :active, -> { where(active: true) }
  scope :available, -> { where("unlimited_stock = ? OR stock_quantity > ?", true, 0) }
  scope :out_of_stock, -> { where(unlimited_stock: false, stock_quantity: 0) }
  scope :ordered, -> { order(:display_order, :id) }

  def available?
    active? && (unlimited_stock? || stock_quantity > 0)
  end

  def out_of_stock?
    active? && !unlimited_stock? && stock_quantity <= 0
  end

  def buy_price
    item.buy_price
  end

  def sell_price
    item.sell_price
  end

  def profit_margin
    return 0 unless sell_price && buy_price > 0
    ((sell_price.to_f - buy_price) / buy_price * 100).round(2)
  end

  def stock_status
    return "無制限" if unlimited_stock?
    return "在庫切れ" if stock_quantity <= 0
    return "残りわずか" if stock_quantity <= 5
    "在庫: #{stock_quantity}"
  end

  def decrease_stock!(quantity = 1)
    return true if unlimited_stock?

    if stock_quantity >= quantity
      update!(stock_quantity: stock_quantity - quantity)
      true
    else
      false
    end
  end

  def increase_stock!(quantity = 1)
    return true if unlimited_stock?

    update!(stock_quantity: stock_quantity + quantity)
    true
  end
end
