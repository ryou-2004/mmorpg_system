class Admin::ContinentsController < ApplicationController
  before_action :set_continent, only: [ :show, :update, :destroy, :regions ]
  before_action :authenticate_admin_user!, unless: :development_test_mode?

  def index
    continents = Continent.all
    continents = continents.active if params[:active] != "false"
    
    render json: {
      continents: continents.map do |continent|
        continent_json(continent).merge(
          regions_count: continent.regions.count,
          active_regions_count: continent.regions.active.count
        )
      end
    }
  end

  def show
    render json: {
      continent: continent_json(@continent),
      regions: @continent.regions.order(:grid_y, :grid_x).map { |r| region_summary(r) },
      grid_data: build_grid_data(@continent)
    }
  end

  def create
    continent = Continent.new(continent_params)
    
    if continent.save
      render json: { 
        continent: continent_json(continent), 
        message: "大陸を作成しました" 
      }, status: :created
    else
      render json: { errors: continent.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @continent.update(continent_params)
      render json: { 
        continent: continent_json(@continent), 
        message: "大陸を更新しました" 
      }
    else
      render json: { errors: @continent.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @continent.regions.exists?
      render json: { 
        error: "地域が存在する大陸は削除できません" 
      }, status: :unprocessable_entity
    else
      @continent.destroy
      render json: { message: "大陸を削除しました" }
    end
  end

  def regions
    regions = @continent.regions
    
    regions = regions.by_type(params[:region_type]) if params[:region_type].present?
    regions = regions.by_terrain(params[:terrain_type]) if params[:terrain_type].present?
    regions = regions.by_level_range(params[:level].to_i) if params[:level].present?
    
    render json: {
      continent: { id: @continent.id, name: @continent.name, display_name: @continent.display_name },
      regions: regions.order(:grid_y, :grid_x).map { |r| region_detail(r) }
    }
  end

  private

  def set_continent
    @continent = Continent.find(params[:id])
  end

  def continent_params
    params.require(:continent).permit(
      :name, :display_name, :description, 
      :world_position_x, :world_position_y,
      :grid_width, :grid_height,
      :unlock_condition, :active
    )
  end

  def continent_json(continent)
    {
      id: continent.id,
      name: continent.name,
      display_name: continent.display_name,
      description: continent.description,
      world_position_x: continent.world_position_x,
      world_position_y: continent.world_position_y,
      world_coordinate: continent.world_coordinate,
      grid_width: continent.grid_width,
      grid_height: continent.grid_height,
      total_regions: continent.total_regions,
      unlock_condition: continent.unlock_condition,
      active: continent.active,
      created_at: continent.created_at,
      updated_at: continent.updated_at
    }
  end

  def region_summary(region)
    {
      id: region.id,
      coordinate: region.coordinate,
      display_name: region.display_name,
      region_type: region.region_type,
      region_type_name: region.region_type_name,
      terrain_type: region.terrain_type,
      terrain_type_name: region.terrain_type_name,
      level_range: region.level_range_display,
      active: region.active
    }
  end

  def region_detail(region)
    region_summary(region).merge(
      name: region.name,
      description: region.description,
      level_range_min: region.level_range_min,
      level_range_max: region.level_range_max,
      climate: region.climate,
      climate_name: region.climate_name,
      accessibility: region.accessibility,
      accessibility_name: region.accessibility_name,
      unlock_condition: region.unlock_condition,
      enemy_spawns_count: region.enemy_spawns.count,
      active_enemies_count: region.enemies.active.distinct.count
    )
  end

  def build_grid_data(continent)
    grid = Array.new(continent.grid_height) { Array.new(continent.grid_width) { nil } }
    
    continent.regions.each do |region|
      x = region.grid_x.ord - 'A'.ord
      y = region.grid_y - 1
      
      grid[y][x] = {
        id: region.id,
        coordinate: region.coordinate,
        display_name: region.display_name,
        region_type: region.region_type,
        terrain_type: region.terrain_type,
        level_range: region.level_range_display,
        active: region.active
      }
    end
    
    grid
  end
end
