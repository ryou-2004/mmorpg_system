class Admin::ShopItemsController < ApplicationController
  before_action :set_shop_item, only: [ :update, :destroy ]
  before_action :set_shop, only: [ :index, :create ]
  before_action :handle_development_test_mode

  def index
    @shop_items = @shop.shop_items.includes(:item)
                       .where(filter_params)
                       .order(order_params)

    render json: {
      shop_items: @shop_items.map { |si| shop_item_json(si) },
      shop: shop_basic_info(@shop),
      stats: shop_item_stats(@shop_items)
    }
  end

  def create
    @shop_item = @shop.shop_items.build(shop_item_params)

    if @shop_item.save
      render json: {
        shop_item: shop_item_json(@shop_item),
        message: "ショップアイテムを追加しました"
      }, status: :created
    else
      render json: { errors: @shop_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @shop_item.update(shop_item_params)
      render json: {
        shop_item: shop_item_json(@shop_item),
        message: "ショップアイテムを更新しました"
      }
    else
      render json: { errors: @shop_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    shop_name = @shop_item.shop.name
    item_name = @shop_item.item.name

    @shop_item.destroy
    render json: {
      message: "#{shop_name}から#{item_name}を削除しました"
    }
  end

  private

  def set_shop_item
    @shop_item = ShopItem.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "ショップアイテムが見つかりません" }, status: :not_found
  end

  def set_shop
    @shop = Shop.find(params[:shop_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "ショップが見つかりません" }, status: :not_found
  end

  def shop_item_params
    params.require(:shop_item).permit(:item_id, :buy_price, :sell_price,
                                     :stock_quantity, :unlimited_stock,
                                     :active, :display_order)
  end

  def filter_params
    filters = {}
    filters[:active] = params[:active] if params[:active].present?
    filters[:unlimited_stock] = params[:unlimited_stock] if params[:unlimited_stock].present?
    filters
  end

  def order_params
    case params[:sort]
    when "name"
      { items: :name }
    when "price"
      :buy_price
    when "stock"
      :stock_quantity
    when "type"
      { items: :item_type }
    else
      [ :display_order, :id ]
    end
  end

  def shop_item_json(shop_item)
    {
      id: shop_item.id,
      shop_id: shop_item.shop_id,
      item_id: shop_item.item_id,
      item_name: shop_item.item.name,
      item_description: shop_item.item.description,
      item_type: shop_item.item.item_type,
      item_rarity: shop_item.item.rarity,
      buy_price: shop_item.buy_price,
      sell_price: shop_item.sell_price,
      stock_quantity: shop_item.stock_quantity,
      unlimited_stock: shop_item.unlimited_stock,
      stock_status: shop_item.stock_status,
      available: shop_item.available?,
      active: shop_item.active,
      display_order: shop_item.display_order,
      profit_margin: shop_item.profit_margin,
      created_at: shop_item.created_at,
      updated_at: shop_item.updated_at
    }
  end

  def shop_basic_info(shop)
    {
      id: shop.id,
      name: shop.name,
      shop_type: shop.shop_type,
      shop_type_name: shop.shop_type_name,
      location: shop.location,
      npc_name: shop.npc_name
    }
  end

  def shop_item_stats(shop_items)
    {
      total_items: shop_items.count,
      active_items: shop_items.count(&:active?),
      available_items: shop_items.count(&:available?),
      out_of_stock_items: shop_items.count(&:out_of_stock?),
      unlimited_stock_items: shop_items.count(&:unlimited_stock?),
      total_value: shop_items.sum(&:buy_price),
      average_price: shop_items.any? ? (shop_items.sum(&:buy_price) / shop_items.count).round : 0,
      price_range: {
        min: shop_items.map(&:buy_price).min || 0,
        max: shop_items.map(&:buy_price).max || 0
      }
    }
  end

  def handle_development_test_mode
    return unless Rails.env.development? && params[:test] == "true"

    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
