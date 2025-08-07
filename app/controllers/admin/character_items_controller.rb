class Admin::CharacterItemsController < Admin::BaseController
  before_action :set_character

  def index
    location = params[:location] || "inventory"
    warehouse_id = params[:warehouse_id]

    items = case location
    when "inventory"
              @character.inventory_items
    when "warehouse"
              if warehouse_id.present?
                warehouse = @character.character_warehouses.find(warehouse_id)
                @character.warehouse_items(warehouse)
              else
                @character.warehouse_items
              end
    when "equipped"
              @character.equipped_items
    else
              @character.character_items.character_accessible
    end

    items = items.order(:location, :created_at)

    render json: {
      data: items.map do |character_item|
        {
          id: character_item.id,
          quantity: character_item.quantity,
          equipped: character_item.equipped?,
          location: character_item.location,
          status: character_item.status,
          locked: character_item.locked?,
          durability: character_item.durability,
          max_durability: character_item.max_durability,
          enchantment_level: character_item.enchantment_level,
          obtained_at: character_item.obtained_at,
          display_status: character_item.display_status,
          status_color: character_item.status_color,
          can_move: character_item.can_move?,
          can_equip: character_item.can_equip?,
          can_use: character_item.can_use?,
          item: {
            id: character_item.item.id,
            name: character_item.item.name,
            description: character_item.item.description,
            item_type: character_item.item.item_type,
            rarity: character_item.item.rarity,
            rarity_color: character_item.item.rarity_color,
            icon_path: character_item.item.icon_path,
            max_stack: character_item.item.max_stack,
            level_requirement: character_item.item.level_requirement,
            effects: character_item.item.effects
          },
          warehouse: character_item.character_warehouse ? {
            id: character_item.character_warehouse.id,
            name: character_item.character_warehouse.name
          } : nil
        }
      end,
      meta: {
        location: location,
        warehouse_id: warehouse_id,
        total_count: items.count,
        character: {
          id: @character.id,
          name: @character.name
        }
      }
    }
  end

  def show
    character_item = @character.character_items.find(params[:id])

    render json: {
      data: {
        id: character_item.id,
        quantity: character_item.quantity,
        equipped: character_item.equipped?,
        location: character_item.location,
        status: character_item.status,
        locked: character_item.locked?,
        durability: character_item.durability,
        max_durability: character_item.max_durability,
        enchantment_level: character_item.enchantment_level,
        obtained_at: character_item.obtained_at,
        display_status: character_item.display_status,
        status_color: character_item.status_color,
        durability_percentage: character_item.durability_percentage,
        can_move: character_item.can_move?,
        can_equip: character_item.can_equip?,
        can_use: character_item.can_use?,
        can_delete: character_item.can_delete?,
        item: {
          id: character_item.item.id,
          name: character_item.item.name,
          description: character_item.item.description,
          item_type: character_item.item.item_type,
          rarity: character_item.item.rarity,
          rarity_color: character_item.item.rarity_color,
          icon_path: character_item.item.icon_path,
          max_stack: character_item.item.max_stack,
          level_requirement: character_item.item.level_requirement,
          job_requirement: character_item.item.job_requirement,
          effects: character_item.item.effects,
          buy_price: character_item.item.buy_price,
          sell_price: character_item.item.sell_price
        },
        warehouse: character_item.character_warehouse ? {
          id: character_item.character_warehouse.id,
          name: character_item.character_warehouse.name,
          max_slots: character_item.character_warehouse.max_slots,
          available_slots: character_item.character_warehouse.available_slots
        } : nil
      }
    }
  end

  def move_to_inventory
    character_item = @character.character_items.find(params[:id])

    unless character_item.can_move?
      render json: {
        success: false,
        message: "このアイテムは移動できません"
      }, status: :unprocessable_entity
      return
    end

    begin
      character_item.move_to_inventory!
      render json: {
        success: true,
        message: "アイテムをインベントリに移動しました",
        item: {
          id: character_item.id,
          name: character_item.item.name,
          location: character_item.location
        }
      }
    rescue StandardError => e
      render json: {
        success: false,
        message: e.message
      }, status: :unprocessable_entity
    end
  end

  def move_to_warehouse
    character_item = @character.character_items.find(params[:id])
    warehouse_id = params[:warehouse_id]

    unless character_item.can_move?
      render json: {
        success: false,
        message: "このアイテムは移動できません"
      }, status: :unprocessable_entity
      return
    end

    if warehouse_id.blank?
      render json: {
        success: false,
        message: "移動先の倉庫を指定してください"
      }, status: :unprocessable_entity
      return
    end

    warehouse = @character.character_warehouses.find(warehouse_id)

    begin
      character_item.move_to_warehouse!(warehouse)
      render json: {
        success: true,
        message: "アイテムを#{warehouse.name}に移動しました",
        item: {
          id: character_item.id,
          name: character_item.item.name,
          location: character_item.location,
          warehouse: {
            id: warehouse.id,
            name: warehouse.name
          }
        }
      }
    rescue StandardError => e
      render json: {
        success: false,
        message: e.message
      }, status: :unprocessable_entity
    end
  end

  def use_item
    character_item = @character.character_items.find(params[:id])

    unless character_item.can_use?
      render json: {
        success: false,
        message: "このアイテムは使用できません"
      }, status: :unprocessable_entity
      return
    end

    begin
      result = character_item.use_item!
      render json: {
        success: true,
        message: result[:message],
        effects: result[:effects],
        item: {
          id: character_item.id,
          name: character_item.item.name,
          quantity: character_item.quantity
        }
      }
    rescue StandardError => e
      render json: {
        success: false,
        message: e.message
      }, status: :unprocessable_entity
    end
  end

  private

  def set_character
    @character = Character.includes(
      :character_warehouses,
      character_items: [ :item, :character_warehouse ]
    ).find(params[:character_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t("messages.errors.character_not_found") }, status: :not_found
  end
end
