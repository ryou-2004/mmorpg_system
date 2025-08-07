class ShopItem < ApplicationRecord
  belongs_to :shop
  belongs_to :item
  has_many :player_shop_purchases, dependent: :destroy

  validates :shop_id, uniqueness: { scope: :item_id }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal: 0 }
  validates :display_order, presence: true, numericality: { greater_than_or_equal: 0 }
  validates :player_stock_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :purchase_reset_type, inclusion: { in: %w[none daily weekly monthly] }

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

  # プレイヤー個別在庫制限があるか
  def has_player_stock_limit?
    player_stock_limit.present?
  end

  # プレイヤーが購入可能かチェック
  def available_for_character?(character, quantity = 1)
    return false unless available?
    return false unless PlayerShopPurchase.can_purchase?(character, self, quantity)
    true
  end

  # プレイヤーの残り購入可能数
  def remaining_quantity_for_character(character)
    return Float::INFINITY unless has_player_stock_limit?
    PlayerShopPurchase.remaining_quantity(character, self)
  end

  # プレイヤーの在庫状況テキスト
  def stock_status_for_character(character)
    if !has_player_stock_limit?
      return stock_status # 通常の在庫状況
    end

    remaining = remaining_quantity_for_character(character)
    if remaining == 0
      "購入上限に達しました"
    elsif remaining <= 5
      "あと#{remaining.to_i}個購入可能"
    else
      "購入可能（上限#{player_stock_limit}個）"
    end
  end

  # リセットタイプの日本語名
  def purchase_reset_type_name
    case purchase_reset_type
    when 'none' then 'リセットなし'
    when 'daily' then '日次リセット'
    when 'weekly' then '週次リセット' 
    when 'monthly' then '月次リセット'
    else purchase_reset_type
    end
  end
end
