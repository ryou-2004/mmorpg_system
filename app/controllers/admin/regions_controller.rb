class Admin::RegionsController < ApplicationController
  before_action :set_region, only: [ :show, :update, :destroy, :enemies ]
  before_action :authenticate_admin_user!, unless: :development_test_mode?

  def index
    regions = Region.includes(:continent)
    
    regions = regions.where(continent_id: params[:continent_id]) if params[:continent_id].present?
    regions = regions.by_type(params[:region_type]) if params[:region_type].present?
    regions = regions.by_terrain(params[:terrain_type]) if params[:terrain_type].present?
    regions = regions.by_level_range(params[:level].to_i) if params[:level].present?
    regions = regions.active if params[:active] != "false"
    
    render json: {
      regions: regions.order(:continent_id, :grid_y, :grid_x).map { |r| region_json(r) }
    }
  end

  def show
    render json: {
      region: region_detail_json(@region),
      enemies: @region.enemies.active.distinct.map { |e| enemy_summary(e) },
      neighbor_regions: @region.neighbors.map { |n| neighbor_summary(n) }
    }
  end

  def create
    region = Region.new(region_params)
    
    if region.save
      render json: { 
        region: region_json(region), 
        message: "地域を作成しました" 
      }, status: :created
    else
      render json: { errors: region.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @region.update(region_params)
      render json: { 
        region: region_json(@region), 
        message: "地域を更新しました" 
      }
    else
      render json: { errors: @region.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @region.enemy_spawns.exists?
      render json: { 
        error: "敵が配置されている地域は削除できません" 
      }, status: :unprocessable_entity
    else
      @region.destroy
      render json: { message: "地域を削除しました" }
    end
  end

  def enemies
    enemies = @region.enemies.includes(:enemy_spawns)
    enemies = enemies.active if params[:active] != "false"
    
    render json: {
      region: { 
        id: @region.id, 
        coordinate: @region.coordinate, 
        display_name: @region.display_name 
      },
      enemies: enemies.distinct.map { |e| 
        enemy_detail(e, @region)
      }
    }
  end

  private

  def set_region
    @region = Region.find(params[:id])
  end

  def region_params
    params.require(:region).permit(
      :continent_id, :grid_x, :grid_y,
      :name, :display_name, :description,
      :region_type, :terrain_type,
      :level_range_min, :level_range_max,
      :climate, :accessibility,
      :unlock_condition, :background_image,
      :background_music, :active
    )
  end

  def region_json(region)
    {
      id: region.id,
      continent_id: region.continent_id,
      continent_name: region.continent.display_name,
      coordinate: region.coordinate,
      grid_x: region.grid_x,
      grid_y: region.grid_y,
      name: region.name,
      display_name: region.display_name,
      region_type: region.region_type,
      region_type_name: region.region_type_name,
      terrain_type: region.terrain_type,
      terrain_type_name: region.terrain_type_name,
      level_range: region.level_range_display,
      level_range_min: region.level_range_min,
      level_range_max: region.level_range_max,
      active: region.active
    }
  end

  def region_detail_json(region)
    region_json(region).merge(
      description: region.description,
      climate: region.climate,
      climate_name: region.climate_name,
      accessibility: region.accessibility,
      accessibility_name: region.accessibility_name,
      unlock_condition: region.unlock_condition,
      background_image: region.background_image,
      background_music: region.background_music,
      enemy_spawns_count: region.enemy_spawns.count,
      active_enemies_count: region.enemies.active.distinct.count,
      created_at: region.created_at,
      updated_at: region.updated_at
    )
  end

  def enemy_summary(enemy)
    {
      id: enemy.id,
      name: enemy.name,
      enemy_type: enemy.enemy_type,
      level: enemy.level,
      power_rating: enemy.power_rating,
      difficulty_rank: enemy.difficulty_rank
    }
  end

  def enemy_detail(enemy, region)
    spawns = enemy.enemy_spawns.where(region: region)
    spawn = spawns.first
    
    enemy_summary(enemy).merge(
      spawn_rate: spawn&.spawn_rate || 0,
      min_level: spawn&.min_level || enemy.level,
      max_level: spawn&.max_level || enemy.level,
      spawn_condition: spawn&.spawn_condition,
      max_spawns: spawn&.max_spawns || 1,
      spawn_active: spawn&.active || false
    )
  end

  def neighbor_summary(neighbor)
    {
      id: neighbor.id,
      coordinate: neighbor.coordinate,
      display_name: neighbor.display_name,
      region_type: neighbor.region_type,
      terrain_type: neighbor.terrain_type,
      level_range: neighbor.level_range_display
    }
  end
end
