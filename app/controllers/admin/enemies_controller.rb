class Admin::EnemiesController < ApplicationController
  before_action :set_enemy, only: [ :show, :update, :destroy ]
  before_action :authenticate_admin_user!, unless: :development_test_mode?

  def index
    enemies = Enemy.includes(:enemy_spawns)

    enemies = filter_by_type(enemies) if params[:enemy_type].present?
    enemies = filter_by_level_range(enemies) if params[:min_level].present? || params[:max_level].present?
    enemies = filter_by_location(enemies) if params[:location].present?
    enemies = enemies.active if params[:active] != "false"

    enemies = enemies.ordered_by_level

    render json: {
      enemies: enemies.map do |enemy|
        {
          id: enemy.id,
          name: enemy.name,
          description: enemy.description,
          enemy_type: enemy.enemy_type,
          enemy_type_name: enemy.enemy_type_name,
          level: enemy.level,
          hp: enemy.hp,
          max_hp: enemy.max_hp,
          mp: enemy.mp,
          max_mp: enemy.max_mp,
          attack: enemy.attack,
          defense: enemy.defense,
          magic_attack: enemy.magic_attack,
          magic_defense: enemy.magic_defense,
          agility: enemy.agility,
          luck: enemy.luck,
          experience_reward: enemy.experience_reward,
          gold_reward: enemy.gold_reward,
          location: enemy.location,
          power_rating: enemy.power_rating,
          difficulty_rank: enemy.difficulty_rank,
          size_category: enemy.size_category,
          size_category_name: enemy.size_category_name,
          battle_ai_type_name: enemy.battle_ai_type_name,
          is_boss: enemy.is_boss?,
          is_elite: enemy.is_elite?,
          spawn_locations: enemy.enemy_spawns.active.count,
          active: enemy.active,
          created_at: enemy.created_at,
          updated_at: enemy.updated_at
        }
      end
    }
  end

  def show
    enemy = @enemy

    render json: {
      enemy: {
        id: enemy.id,
        name: enemy.name,
        description: enemy.description,
        enemy_type: enemy.enemy_type,
        enemy_type_name: enemy.enemy_type_name,
        level: enemy.level,
        hp: enemy.hp,
        max_hp: enemy.max_hp,
        mp: enemy.mp,
        max_mp: enemy.max_mp,
        attack: enemy.attack,
        defense: enemy.defense,
        magic_attack: enemy.magic_attack,
        magic_defense: enemy.magic_defense,
        agility: enemy.agility,
        luck: enemy.luck,
        experience_reward: enemy.experience_reward,
        gold_reward: enemy.gold_reward,
        location: enemy.location,
        appearance: enemy.appearance,
        skills: enemy.skills,
        skills_summary: enemy.skills_summary,
        resistances: enemy.resistances,
        resistances_summary: enemy.resistances_summary,
        drop_table: enemy.drop_table,
        drop_items_summary: enemy.drop_items_summary,
        battle_ai_type: enemy.battle_ai_type,
        battle_ai_type_name: enemy.battle_ai_type_name,
        spawn_rate: enemy.spawn_rate,
        size_category: enemy.size_category,
        size_category_name: enemy.size_category_name,
        power_rating: enemy.power_rating,
        difficulty_rank: enemy.difficulty_rank,
        is_boss: enemy.is_boss?,
        is_elite: enemy.is_elite?,
        active: enemy.active,
        created_at: enemy.created_at,
        updated_at: enemy.updated_at
      },
      spawn_locations: enemy.enemy_spawns.includes(:enemy).map do |spawn|
        {
          id: spawn.id,
          location: spawn.location,
          spawn_rate: spawn.spawn_rate,
          level_range_display: spawn.level_range_display,
          min_level: spawn.min_level,
          max_level: spawn.max_level,
          spawn_condition: spawn.spawn_condition,
          spawn_condition_name: spawn.spawn_condition_name,
          max_spawns: spawn.max_spawns,
          active: spawn.active
        }
      end
    }
  end

  def create
    enemy = Enemy.new(enemy_params)

    if enemy.save
      render json: { enemy: format_enemy_response(enemy) }, status: :created
    else
      render json: { errors: enemy.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @enemy.update(enemy_params)
      render json: { enemy: format_enemy_response(@enemy) }
    else
      render json: { errors: @enemy.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @enemy.destroy
    render json: { message: "敵キャラが削除されました" }
  end

  def encounter_simulation
    location = params[:location]
    player_level = params[:player_level]&.to_i || 1

    return render json: { error: "場所を指定してください" }, status: :bad_request if location.blank?

    spawns = EnemySpawn.active
                      .by_location(location)
                      .for_level_range(player_level)
                      .includes(:enemy)

    encounter_table = spawns.map do |spawn|
      weight = spawn.weighted_spawn_rate_for_player(player_level)
      next if weight <= 0

      {
        enemy: {
          id: spawn.enemy.id,
          name: spawn.enemy.name,
          level: spawn.enemy.level,
          enemy_type_name: spawn.enemy.enemy_type_name,
          difficulty_rank: spawn.enemy.difficulty_rank,
          power_rating: spawn.enemy.power_rating
        },
        spawn_weight: weight,
        spawn_condition_name: spawn.spawn_condition_name,
        level_range_display: spawn.level_range_display
      }
    end.compact

    total_weight = encounter_table.sum { |entry| entry[:spawn_weight] }

    render json: {
      location: location,
      player_level: player_level,
      total_encounters: encounter_table.size,
      total_weight: total_weight,
      encounters: encounter_table.sort_by { |entry| -entry[:spawn_weight] }
    }
  end

  private

  def set_enemy
    @enemy = Enemy.find(params[:id])
  end

  def enemy_params
    params.require(:enemy).permit(
      :name, :description, :enemy_type, :level,
      :hp, :max_hp, :mp, :max_mp,
      :attack, :defense, :magic_attack, :magic_defense, :agility, :luck,
      :experience_reward, :gold_reward, :location, :appearance,
      :battle_ai_type, :spawn_rate, :size_category, :active,
      skills: [], resistances: {}, drop_table: []
    )
  end

  def filter_by_type(enemies)
    enemies.by_type(params[:enemy_type])
  end

  def filter_by_level_range(enemies)
    min_level = params[:min_level]&.to_i
    max_level = params[:max_level]&.to_i

    if min_level && max_level
      enemies.by_level_range(min_level, max_level)
    elsif min_level
      enemies.where("level >= ?", min_level)
    elsif max_level
      enemies.where("level <= ?", max_level)
    else
      enemies
    end
  end

  def filter_by_location(enemies)
    enemies.by_location(params[:location])
  end

  def format_enemy_response(enemy)
    {
      id: enemy.id,
      name: enemy.name,
      description: enemy.description,
      enemy_type: enemy.enemy_type,
      enemy_type_name: enemy.enemy_type_name,
      level: enemy.level,
      hp: enemy.hp,
      max_hp: enemy.max_hp,
      mp: enemy.mp,
      max_mp: enemy.max_mp,
      attack: enemy.attack,
      defense: enemy.defense,
      magic_attack: enemy.magic_attack,
      magic_defense: enemy.magic_defense,
      agility: enemy.agility,
      luck: enemy.luck,
      experience_reward: enemy.experience_reward,
      gold_reward: enemy.gold_reward,
      location: enemy.location,
      appearance: enemy.appearance,
      skills: enemy.skills,
      skills_summary: enemy.skills_summary,
      resistances: enemy.resistances,
      resistances_summary: enemy.resistances_summary,
      drop_table: enemy.drop_table,
      drop_items_summary: enemy.drop_items_summary,
      battle_ai_type: enemy.battle_ai_type,
      battle_ai_type_name: enemy.battle_ai_type_name,
      spawn_rate: enemy.spawn_rate,
      size_category: enemy.size_category,
      size_category_name: enemy.size_category_name,
      power_rating: enemy.power_rating,
      difficulty_rank: enemy.difficulty_rank,
      is_boss: enemy.is_boss?,
      is_elite: enemy.is_elite?,
      active: enemy.active,
      created_at: enemy.created_at,
      updated_at: enemy.updated_at
    }
  end

  def authenticate_admin_user!
    return if params[:test] == "true" && Rails.env.development?
    head :unauthorized unless current_admin_user
  end
end
