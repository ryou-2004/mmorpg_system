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
          rarity_name: armor.rarity_name,
          level_requirement: armor.level_requirement,
          buy_price: armor.buy_price,
          sell_price: armor.sell_price,
          is_shield: armor.is_shield?,
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
        rarity_name: @armor.rarity_name,
        max_stack: @armor.max_stack,
        buy_price: @armor.buy_price,
        sell_price: @armor.sell_price,
        level_requirement: @armor.level_requirement,
        job_requirement: @armor.job_requirement,
        effects: @armor.effects,
        formatted_effects: @armor.formatted_effects,
        icon_path: @armor.icon_path,
        sale_type: @armor.sale_type,
        is_shield: @armor.is_shield?,
        active: @armor.active,
        character_count: @armor.character_items.count,
        created_at: @armor.created_at,
        updated_at: @armor.updated_at
      }
    }
  end

  def create
    @armor = Armor.new(armor_params)
    if @armor.save
      render json: { armor: armor_json(@armor) }, status: :created
    else
      render json: { errors: @armor.errors.full_messages }, status: :unprocessable_entity
    end
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
    render json: { message: I18n.t('messages.success.deleted', model: I18n.t('activerecord.models.armor')) }
  end

  private

  def set_armor
    @armor = Armor.find(params[:id])
  end

  def armor_params
    params.require(:armor).permit(
      :name, :description, :armor_category, :rarity, :max_stack,
      :buy_price, :sell_price, :level_requirement,
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
      sale_type: armor.sale_type,
      is_shield: armor.is_shield?,
      active: armor.active,
      created_at: armor.created_at,
      updated_at: armor.updated_at
    }
  end
end
