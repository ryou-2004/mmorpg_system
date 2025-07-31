class Admin::PlayerItemsController < ApplicationController
  before_action :authenticate_admin_user!, unless: -> { Rails.env.test? || development_test_mode? }
  before_action :set_player

  def index
    location = params[:location] || 'inventory'
    warehouse_id = params[:warehouse_id]
    
    items = case location
            when 'inventory'
              @player.inventory_items
            when 'warehouse'
              if warehouse_id.present?
                warehouse = @player.player_warehouses.find(warehouse_id)
                @player.warehouse_items(warehouse)
              else
                @player.warehouse_items
              end
            when 'equipped'
              @player.equipped_items
            else
              @player.player_items.player_accessible
            end

    items = items.order(:location, :created_at)

    render json: {
      data: items.map do |player_item|
        {
          id: player_item.id,
          quantity: player_item.quantity,
          equipped: player_item.equipped?,
          location: player_item.location,
          status: player_item.status,
          locked: player_item.locked?,
          durability: player_item.durability,
          max_durability: player_item.max_durability,
          enchantment_level: player_item.enchantment_level,
          obtained_at: player_item.obtained_at,
          display_status: player_item.display_status,
          status_color: player_item.status_color,
          can_move: player_item.can_move?,
          can_equip: player_item.can_equip?,
          can_use: player_item.can_use?,
          item: {
            id: player_item.item.id,
            name: player_item.item.name,
            description: player_item.item.description,
            item_type: player_item.item.item_type,
            rarity: player_item.item.rarity,
            rarity_color: player_item.item.rarity_color,
            icon_path: player_item.item.icon_path,
            max_stack: player_item.item.max_stack,
            level_requirement: player_item.item.level_requirement,
            effects: player_item.item.effects
          },
          warehouse: player_item.player_warehouse ? {
            id: player_item.player_warehouse.id,
            name: player_item.player_warehouse.name
          } : nil
        }
      end,
      meta: {
        location: location,
        warehouse_id: warehouse_id,
        total_count: items.count,
        player: {
          id: @player.id,
          name: @player.name
        }
      }
    }
  end

  def show
    player_item = @player.player_items.find(params[:id])
    
    render json: {
      data: {
        id: player_item.id,
        quantity: player_item.quantity,
        equipped: player_item.equipped?,
        location: player_item.location,
        status: player_item.status,
        locked: player_item.locked?,
        durability: player_item.durability,
        max_durability: player_item.max_durability,
        enchantment_level: player_item.enchantment_level,
        obtained_at: player_item.obtained_at,
        display_status: player_item.display_status,
        status_color: player_item.status_color,
        durability_percentage: player_item.durability_percentage,
        can_move: player_item.can_move?,
        can_equip: player_item.can_equip?,
        can_use: player_item.can_use?,
        can_delete: player_item.can_delete?,
        item: {
          id: player_item.item.id,
          name: player_item.item.name,
          description: player_item.item.description,
          item_type: player_item.item.item_type,
          rarity: player_item.item.rarity,
          rarity_color: player_item.item.rarity_color,
          icon_path: player_item.item.icon_path,
          max_stack: player_item.item.max_stack,
          level_requirement: player_item.item.level_requirement,
          job_requirement: player_item.item.job_requirement,
          effects: player_item.item.effects,
          buy_price: player_item.item.buy_price,
          sell_price: player_item.item.sell_price
        },
        warehouse: player_item.player_warehouse ? {
          id: player_item.player_warehouse.id,
          name: player_item.player_warehouse.name,
          max_slots: player_item.player_warehouse.max_slots,
          available_slots: player_item.player_warehouse.available_slots
        } : nil
      }
    }
  end

  private

  def set_player
    @player = Player.includes(
      :player_warehouses,
      player_items: [:item, :player_warehouse]
    ).find(params[:player_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "プレイヤーが見つかりません" }, status: :not_found
  end

  def development_test_mode?
    Rails.env.development? && params[:test] == "true"
  end
end
