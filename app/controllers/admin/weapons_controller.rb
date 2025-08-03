class Admin::WeaponsController < ApplicationController
  before_action :set_weapon, only: [:show, :update, :destroy]

  def index
    @weapons = Weapon.includes(:character_items).order(:weapon_category, :rarity, :name)
    
    if params[:search].present?
      @weapons = @weapons.where("name LIKE ?", "%#{params[:search]}%")
    end
    
    if params[:weapon_category].present?
      @weapons = @weapons.where(weapon_category: params[:weapon_category])
    end
    
    if params[:rarity].present?
      @weapons = @weapons.where(rarity: params[:rarity])
    end
    
    if params[:active].present?
      @weapons = @weapons.where(active: params[:active] == 'true')
    end

    render json: {
      weapons: @weapons.map do |weapon|
        {
          id: weapon.id,
          name: weapon.name,
          weapon_category: weapon.weapon_category,
          weapon_category_name: weapon.weapon_category_name,
          rarity: weapon.rarity,
          level_requirement: weapon.level_requirement,
          buy_price: weapon.buy_price,
          sell_price: weapon.sell_price,
          equipment_slot: weapon.equipment_slot,
          one_handed: weapon.one_handed?,
          two_handed: weapon.two_handed?,
          attack_type: weapon.attack_type,
          active: weapon.active,
          character_count: weapon.character_items.count,
          created_at: weapon.created_at,
          updated_at: weapon.updated_at
        }
      end,
      meta: {
        current_page: 1,
        total_pages: 1,
        total_count: @weapons.count
      }
    }
  end

  def show
    render json: {
      weapon: {
        id: @weapon.id,
        name: @weapon.name,
        description: @weapon.description,
        weapon_category: @weapon.weapon_category,
        weapon_category_name: @weapon.weapon_category_name,
        rarity: @weapon.rarity,
        max_stack: @weapon.max_stack,
        buy_price: @weapon.buy_price,
        sell_price: @weapon.sell_price,
        level_requirement: @weapon.level_requirement,
        job_requirement: @weapon.job_requirement,
        effects: @weapon.effects,
        formatted_effects: @weapon.formatted_effects,
        icon_path: @weapon.icon_path,
        equipment_slot: @weapon.equipment_slot,
        sale_type: @weapon.sale_type,
        one_handed: @weapon.one_handed?,
        two_handed: @weapon.two_handed?,
        can_use_left_hand: @weapon.can_use_left_hand?,
        attack_type: @weapon.attack_type,
        physical: @weapon.physical?,
        magical: @weapon.magical?,
        ranged: @weapon.ranged?,
        active: @weapon.active,
        character_count: @weapon.character_items.count,
        created_at: @weapon.created_at,
        updated_at: @weapon.updated_at
      }
    }
  end

  def create
    @weapon = Weapon.new(weapon_params)
    if @weapon.save
      render json: { weapon: weapon_json(@weapon) }, status: :created
    else
      render json: { errors: @weapon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @weapon.update(weapon_params)
      render json: { weapon: weapon_json(@weapon) }
    else
      render json: { errors: @weapon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @weapon.destroy
    render json: { message: "武器が削除されました" }
  end

  private

  def set_weapon
    @weapon = Weapon.find(params[:id])
  end

  def weapon_params
    params.require(:weapon).permit(
      :name, :description, :weapon_category, :rarity, :max_stack,
      :buy_price, :sell_price, :level_requirement,
      :sale_type, :icon_path, :active,
      job_requirement: [], effects: []
    )
  end

  def weapon_json(weapon)
    {
      id: weapon.id,
      name: weapon.name,
      description: weapon.description,
      weapon_category: weapon.weapon_category,
      weapon_category_name: weapon.weapon_category_name,
      rarity: weapon.rarity,
      max_stack: weapon.max_stack,
      buy_price: weapon.buy_price,
      sell_price: weapon.sell_price,
      level_requirement: weapon.level_requirement,
      job_requirement: weapon.job_requirement,
      effects: weapon.effects,
      icon_path: weapon.icon_path,
      equipment_slot: weapon.equipment_slot,
      sale_type: weapon.sale_type,
      one_handed: weapon.one_handed?,
      two_handed: weapon.two_handed?,
      attack_type: weapon.attack_type,
      active: weapon.active,
      created_at: weapon.created_at,
      updated_at: weapon.updated_at
    }
  end
end
