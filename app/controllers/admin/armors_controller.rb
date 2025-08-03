class Admin::ArmorsController < ApplicationController
  before_action :set_armor, only: [:show, :update, :destroy]

  def index
    @armors = Armor.includes(:character_items).order(:armor_category, :rarity, :name)
    
    if params[:search].present?
      @armors = @armors.where("name LIKE ?", "%#{params[:search]}%")
    end
    
    if params[:armor_category].present?
      @armors = @armors.where(armor_category: params[:armor_category])
    end
    
    if params[:rarity].present?
      @armors = @armors.where(rarity: params[:rarity])
    end
    
    if params[:active].present?
      @armors = @armors.where(active: params[:active] == 'true')
    end

    render json: {
      armors: @armors.map do |armor|
        {
          id: armor.id,
          name: armor.name,
          armor_category: armor.armor_category,
          armor_category_name: armor.armor_category_name,
          rarity: armor.rarity,
          level_requirement: armor.level_requirement,
          buy_price: armor.buy_price,
          sell_price: armor.sell_price,
          equipment_slot: armor.equipment_slot,
          is_shield: armor.is_shield?,
          covers_torso: armor.covers_torso?,
          covers_limbs: armor.covers_limbs?,
          covers_head: armor.covers_head?,
          active: armor.active,
          character_count: armor.character_items.count,
          created_at: armor.created_at,
          updated_at: armor.updated_at
        }
      end,
      meta: {
        current_page: 1,
        total_pages: 1,
        total_count: @armors.count
      }
    }
  end

  def show
    render json: {
      armor: {
        id: @armor.id,
        name: @armor.name,
        description: @armor.description,
        armor_category: @armor.armor_category,
        armor_category_name: @armor.armor_category_name,
        rarity: @armor.rarity,
        max_stack: @armor.max_stack,
        buy_price: @armor.buy_price,
        sell_price: @armor.sell_price,
        level_requirement: @armor.level_requirement,
        job_requirement: @armor.job_requirement,
        effects: @armor.effects,
        icon_path: @armor.icon_path,
        equipment_slot: @armor.equipment_slot,
        sale_type: @armor.sale_type,
        is_shield: @armor.is_shield?,
        covers_torso: @armor.covers_torso?,
        covers_limbs: @armor.covers_limbs?,
        covers_head: @armor.covers_head?,
        defense_slot: @armor.defense_slot,
        active: @armor.active,
        character_count: @armor.character_items.count,
        created_at: @armor.created_at,
        updated_at: @armor.updated_at
      }
    }
  end

  def update
    if @armor.update(armor_params)
      render json: { armor: armor_json(@armor) }
    else
      render json: { errors: @armor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @armor.destroy
    render json: { message: "防具が削除されました" }
  end

  private

  def set_armor
    @armor = Armor.find(params[:id])
  end

  def armor_params
    params.require(:armor).permit(
      :name, :description, :armor_category, :rarity, :max_stack,
      :buy_price, :sell_price, :level_requirement, :equipment_slot,
      :sale_type, :icon_path, :active,
      job_requirement: [], effects: []
    )
  end

  def armor_json(armor)
    {
      id: armor.id,
      name: armor.name,
      description: armor.description,
      armor_category: armor.armor_category,
      armor_category_name: armor.armor_category_name,
      rarity: armor.rarity,
      max_stack: armor.max_stack,
      buy_price: armor.buy_price,
      sell_price: armor.sell_price,
      level_requirement: armor.level_requirement,
      job_requirement: armor.job_requirement,
      effects: armor.effects,
      icon_path: armor.icon_path,
      equipment_slot: armor.equipment_slot,
      sale_type: armor.sale_type,
      is_shield: armor.is_shield?,
      covers_torso: armor.covers_torso?,
      active: armor.active,
      created_at: armor.created_at,
      updated_at: armor.updated_at
    }
  end
end
