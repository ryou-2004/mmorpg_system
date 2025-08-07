class PlayerShopPurchase < ApplicationRecord
  belongs_to :character
  belongs_to :shop_item

  validates :character_id, uniqueness: { scope: :shop_item_id }
  validates :purchased_quantity, presence: true, numericality: { greater_than_or_equal: 0 }

  scope :for_character, ->(character) { where(character: character) }
  scope :for_shop_item, ->(shop_item) { where(shop_item: shop_item) }
  scope :recent, -> { order(last_purchased_at: :desc) }

  # プレイヤーが特定のショップアイテムを購入可能か判定
  def self.can_purchase?(character, shop_item, quantity = 1)
    return true unless shop_item.has_player_stock_limit?

    purchase_record = find_by(character: character, shop_item: shop_item)
    return true unless purchase_record

    # リセット時刻チェック
    if should_reset?(purchase_record, shop_item)
      reset_purchase_record!(purchase_record, shop_item)
      return true
    end

    # 購入制限チェック
    remaining = shop_item.player_stock_limit - purchase_record.purchased_quantity
    remaining >= quantity
  end

  # プレイヤーの残り購入可能数を取得
  def self.remaining_quantity(character, shop_item)
    return Float::INFINITY unless shop_item.has_player_stock_limit?

    purchase_record = find_by(character: character, shop_item: shop_item)
    return shop_item.player_stock_limit unless purchase_record

    # リセット時刻チェック
    if should_reset?(purchase_record, shop_item)
      return shop_item.player_stock_limit
    end

    [shop_item.player_stock_limit - purchase_record.purchased_quantity, 0].max
  end

  # 購入記録を更新
  def self.record_purchase!(character, shop_item, quantity)
    return unless shop_item.has_player_stock_limit?

    purchase_record = find_or_create_by(
      character: character, 
      shop_item: shop_item
    )

    # リセット時刻チェック
    if should_reset?(purchase_record, shop_item)
      reset_purchase_record!(purchase_record, shop_item)
    end

    purchase_record.update!(
      purchased_quantity: purchase_record.purchased_quantity + quantity,
      last_purchased_at: Time.current
    )
  end

  private

  # リセットが必要かチェック
  def self.should_reset?(purchase_record, shop_item)
    return false if shop_item.purchase_reset_type == 'none'
    return false if purchase_record.reset_at.nil?

    case shop_item.purchase_reset_type
    when 'daily'
      purchase_record.reset_at < Time.current.beginning_of_day
    when 'weekly'
      purchase_record.reset_at < Time.current.beginning_of_week
    when 'monthly'
      purchase_record.reset_at < Time.current.beginning_of_month
    else
      false
    end
  end

  # 購入記録をリセット
  def self.reset_purchase_record!(purchase_record, shop_item)
    next_reset = case shop_item.purchase_reset_type
    when 'daily'
      Time.current.end_of_day
    when 'weekly'
      Time.current.end_of_week
    when 'monthly'
      Time.current.end_of_month
    else
      nil
    end

    purchase_record.update!(
      purchased_quantity: 0,
      reset_at: next_reset
    )
  end
end