class Admin::ShopsController < ApplicationController
  before_action :set_shop, only: [ :show, :update, :destroy ]
  before_action :handle_development_test_mode

  def index
    @shops = Shop.includes(:shop_items, :items)
                 .where(filter_params)
                 .order(order_params)
                 .limit(limit_params)
                 .offset(offset_params)

    render json: {
      shops: @shops.map { |shop| shop_json(shop) },
      meta: {
        total_count: Shop.where(filter_params).count,
        page: page_params,
        per_page: limit_params,
        total_pages: (Shop.where(filter_params).count.to_f / limit_params).ceil
      },
      stats: shop_stats
    }
  end

  def show
    render json: {
      shop: shop_detail_json(@shop),
      shop_items: @shop.shop_items.includes(:item).active.ordered.map { |si| shop_item_json(si) },
      available_items: available_items_for_shop,
      stats: shop_item_stats(@shop)
    }
  end

  def create
    @shop = Shop.new(shop_params)

    if @shop.save
      render json: { shop: shop_detail_json(@shop) }, status: :created
    else
      render json: { errors: @shop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @shop.update(shop_params)
      render json: { shop: shop_detail_json(@shop) }
    else
      render json: { errors: @shop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @shop.shop_items.exists?
      render json: { error: "ショップアイテムが存在するため削除できません" }, status: :unprocessable_entity
    else
      @shop.destroy
      render json: { message: "ショップを削除しました" }
    end
  end

  private

  def set_shop
    @shop = Shop.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "ショップが見つかりません" }, status: :not_found
  end

  def shop_params
    params.require(:shop).permit(:name, :description, :shop_type, :location,
                                 :npc_name, :active, :display_order)
  end

  def filter_params
    filters = {}
    filters[:shop_type] = params[:shop_type] if params[:shop_type].present?
    filters[:location] = params[:location] if params[:location].present?
    filters[:active] = params[:active] if params[:active].present?
    filters
  end

  def order_params
    case params[:sort]
    when "name"
      :name
    when "type"
      :shop_type
    when "location"
      :location
    when "items"
      # 複雑な並び順なのでSQLで処理
      "shop_items_count DESC"
    else
      [ :display_order, :id ]
    end
  end

  def limit_params
    [ (params[:per_page] || 20).to_i, 100 ].min
  end

  def offset_params
    (page_params - 1) * limit_params
  end

  def page_params
    [ params[:page].to_i, 1 ].max
  end

  def shop_json(shop)
    {
      id: shop.id,
      name: shop.name,
      description: shop.description,
      shop_type: shop.shop_type,
      shop_type_name: shop.shop_type_name,
      location: shop.location,
      npc_name: shop.npc_name,
      active: shop.active,
      display_order: shop.display_order,
      active_items_count: shop.active_items_count,
      total_items_value: shop.total_items_value,
      created_at: shop.created_at,
      updated_at: shop.updated_at
    }
  end

  def shop_detail_json(shop)
    shop_json(shop).merge({
      available_items_count: shop.available_items.count,
      out_of_stock_items_count: shop.out_of_stock_items.count
    })
  end

  def shop_item_json(shop_item)
    {
      id: shop_item.id,
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
      profit_margin: shop_item.profit_margin
    }
  end

  def available_items_for_shop
    # ショップに未登録のアイテム一覧を取得
    registered_item_ids = @shop.shop_items.pluck(:item_id)
    Item.active.where.not(id: registered_item_ids).limit(50).map do |item|
      {
        id: item.id,
        name: item.name,
        description: item.description,
        item_type: item.item_type,
        rarity: item.rarity,
        default_buy_price: item.buy_price,
        default_sell_price: item.sell_price
      }
    end
  end

  def shop_item_stats(shop)
    shop_items = shop.shop_items.active

    {
      total_items: shop_items.count,
      available_items: shop_items.available.count,
      out_of_stock_items: shop_items.out_of_stock.count,
      unlimited_stock_items: shop_items.where(unlimited_stock: true).count,
      total_value: shop_items.sum(:buy_price),
      average_price: shop_items.count > 0 ? (shop_items.sum(:buy_price) / shop_items.count).round : 0,
      price_range: {
        min: shop_items.minimum(:buy_price) || 0,
        max: shop_items.maximum(:buy_price) || 0
      }
    }
  end

  def shop_stats
    {
      total_shops: Shop.count,
      active_shops: Shop.active.count,
      total_shop_items: ShopItem.count,
      available_shop_items: ShopItem.available.count,
      shop_types: Shop.group(:shop_type).count.transform_keys { |k| Shop.new(shop_type: k).shop_type_name },
      locations: Shop.where.not(location: [ nil, "" ]).group(:location).count
    }
  end

  def handle_development_test_mode
    return unless Rails.env.development? && params[:test] == "true"

    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
