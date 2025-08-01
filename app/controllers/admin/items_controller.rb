class Admin::ItemsController < ApplicationController
  before_action :authenticate_admin_user!, unless: -> { Rails.env.test? || development_test_mode? }
  before_action :set_item, only: [ :show, :update, :destroy ]

  def index
    items = Item.order(:item_type, :rarity, :name)

    # フィルタリング
    items = items.where(item_type: params[:item_type]) if params[:item_type].present?
    items = items.where(rarity: params[:rarity]) if params[:rarity].present?
    items = items.where(active: params[:active]) if params[:active].present?

    render json: {
      data: items.map do |item|
        {
          id: item.id,
          name: item.name,
          description: item.description,
          item_type: item.item_type,
          rarity: item.rarity,
          max_stack: item.max_stack,
          buy_price: item.buy_price,
          sell_price: item.sell_price,
          level_requirement: item.level_requirement,
          job_requirement: item.job_requirement,
          effects: item.effects,
          sale_type: item.sale_type,
          icon_path: item.icon_path,
          active: item.active,
          created_at: item.created_at
        }
      end
    }
  end

  def show
    # アイテム統計情報を効率的に取得
    item_stats = calculate_item_statistics(@item)

    render json: {
      data: {
        id: @item.id,
        name: @item.name,
        description: @item.description,
        item_type: @item.item_type,
        rarity: @item.rarity,
        max_stack: @item.max_stack,
        buy_price: @item.buy_price,
        sell_price: @item.sell_price,
        level_requirement: @item.level_requirement,
        job_requirement: @item.job_requirement,
        effects: @item.effects,
        sale_type: @item.sale_type,
        icon_path: @item.icon_path,
        active: @item.active,
        created_at: @item.created_at,
        updated_at: @item.updated_at,
        statistics: item_stats
      }
    }
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      render json: {
        data: item_json(@item),
        message: "アイテムが作成されました"
      }, status: :created
    else
      render json: {
        errors: @item.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      render json: {
        data: item_json(@item),
        message: "アイテムが更新されました"
      }
    else
      render json: {
        errors: @item.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    render json: {
      message: "アイテムが削除されました"
    }
  end

  private

  def set_item
    @item = Item.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "アイテムが見つかりません" }, status: :not_found
  end

  def item_params
    params.require(:item).permit(
      :name, :description, :item_type, :rarity, :max_stack,
      :buy_price, :sell_price, :level_requirement, :sale_type,
      :icon_path, :active,
      job_requirement: [],
      effects: []
    )
  end

  def item_json(item)
    {
      id: item.id,
      name: item.name,
      description: item.description,
      item_type: item.item_type,
      rarity: item.rarity,
      max_stack: item.max_stack,
      buy_price: item.buy_price,
      sell_price: item.sell_price,
      level_requirement: item.level_requirement,
      job_requirement: item.job_requirement,
      effects: item.effects,
      sale_type: item.sale_type,
      icon_path: item.icon_path,
      active: item.active,
      created_at: item.created_at,
      updated_at: item.updated_at
    }
  end

  def development_test_mode?
    Rails.env.development? && params[:test] == "true"
  end

  # アイテム統計情報を計算
  def calculate_item_statistics(item)
    player_items = PlayerItem.where(item: item).player_accessible

    # 基本統計
    total_items = player_items.sum(:quantity)
    players_with_item = player_items.joins(:player).distinct.count(:player_id)

    # プレイヤーごとの所持数を取得
    player_quantities = player_items.joins(:player)
                                   .group(:player_id)
                                   .sum(:quantity)
                                   .values

    # 統計計算
    average_per_player = if players_with_item > 0
                          player_quantities.sum.to_f / players_with_item
    else
                          0
    end

    # 中央値計算
    median_per_player = if player_quantities.empty?
                         0
    else
                         sorted_quantities = player_quantities.sort
                         mid = sorted_quantities.length / 2
                         if sorted_quantities.length.odd?
                           sorted_quantities[mid]
                         else
                           (sorted_quantities[mid - 1] + sorted_quantities[mid]) / 2.0
                         end
    end

    {
      total_items: total_items,
      players_with_item: players_with_item,
      average_per_player: average_per_player.round(2),
      median_per_player: median_per_player,
      max_per_player: player_quantities.max || 0,
      min_per_player: player_quantities.min || 0
    }
  end
end
