class Admin::ItemsController < ApplicationController
  before_action :authenticate_admin_user!, unless: :development_test_mode?
  before_action :set_item, only: [:show, :update, :destroy]

  def index
    items = Item.includes(:players)
                .order(:item_type, :rarity, :name)

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
          players_count: item.players.count,
          created_at: item.created_at
        }
      end
    }
  end

  def show
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
        players_count: @item.players.count,
        created_at: @item.created_at,
        updated_at: @item.updated_at
      }
    }
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      render json: {
        data: item_json(@item),
        message: 'アイテムが作成されました'
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
        message: 'アイテムが更新されました'
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
      message: 'アイテムが削除されました'
    }
  end

  private

  def set_item
    @item = Item.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'アイテムが見つかりません' }, status: :not_found
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
    Rails.env.development? && params[:test] == 'true'
  end
end
