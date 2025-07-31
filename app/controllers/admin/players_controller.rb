class Admin::PlayersController < ApplicationController
  before_action :authenticate_admin_user!, unless: -> { Rails.env.test? || development_test_mode? }

  def index
    players = Player.includes(:user, current_job_class: :job_class)
                   .order(created_at: :desc)

    render json: {
      data: players.map do |player|
        {
          id: player.id,
          name: player.name,
          gold: player.gold,
          active: player.active,
          created_at: player.created_at,
          last_login_at: player.last_login_at,
          current_job: player.current_job_class ? {
            job_name: player.current_job_name,
            level: player.level,
            experience: player.experience,
            skill_points: player.skill_points,
            stats: {
              hp: player.hp,
              max_hp: player.max_hp,
              mp: player.mp,
              max_mp: player.max_mp,
              attack: player.attack,
              defense: player.defense,
              magic_attack: player.magic_attack,
              magic_defense: player.magic_defense,
              agility: player.agility,
              luck: player.luck
            }
          } : nil,
          user: {
            id: player.user.id,
            name: player.user.name,
            email: player.user.email
          }
        }
      end
    }
  end

  def show
    player = Player.includes(:user, :player_warehouses, current_job_class: :job_class, player_job_classes: :job_class)
                   .find(params[:id])
    
    # パフォーマンス最適化されたカウントメソッドを使用

    render json: {
      id: player.id,
      name: player.name,
      gold: player.gold,
      active: player.active,
      created_at: player.created_at,
      last_login_at: player.last_login_at,
      current_job_class: player.current_job_class ? {
        id: player.current_job_class.id,
        level: player.level,
        experience: player.experience,
        skill_points: player.skill_points,
        job_class: {
          id: player.current_job_class.job_class.id,
          name: player.current_job_name,
          job_type: player.current_job_class.job_class.job_type
        }
      } : nil,
      user: {
        id: player.user.id,
        name: player.user.name,
        email: player.user.email
      },
      job_classes: player.player_job_classes.includes(:job_class).map do |pjc|
        {
          id: pjc.id,
          job_class: {
            id: pjc.job_class.id,
            name: pjc.job_class.name,
            job_type: pjc.job_class.job_type,
            max_level: pjc.job_class.max_level
          },
          level: pjc.level,
          experience: pjc.experience,
          skill_points: pjc.skill_points,
          exp_to_next_level: pjc.exp_to_next_level,
          level_progress: pjc.level_progress,
          unlocked_at: pjc.unlocked_at,
          is_current: player.current_job_class_id == pjc.id,
          stats: {
            hp: pjc.hp,
            max_hp: pjc.max_hp,
            mp: pjc.mp,
            max_mp: pjc.max_mp,
            attack: pjc.attack,
            defense: pjc.defense,
            magic_attack: pjc.magic_attack,
            magic_defense: pjc.magic_defense,
            agility: pjc.agility,
            luck: pjc.luck
          }
        }
      end,
      warehouses: player.player_warehouses.map do |warehouse|
        {
          id: warehouse.id,
          name: warehouse.name,
          max_slots: warehouse.max_slots,
          used_slots: player.warehouse_usage_by_id[warehouse.id] || 0
        }
      end,
      inventory_count: player.inventory_count,
      equipped_count: player.equipped_count
    }
  end

  def switch_job
    player = Player.find(params[:id])
    job_class = JobClass.find(params[:job_class_id])

    begin
      player.switch_job!(job_class)

      render json: {
        success: true,
        message: "職業を#{job_class.name}に変更しました",
        current_job: {
          job_name: player.current_job_name,
          level: player.level,
          experience: player.experience,
          skill_points: player.skill_points,
          stats: {
            hp: player.hp,
            max_hp: player.max_hp,
            mp: player.mp,
            max_mp: player.max_mp,
            attack: player.attack,
            defense: player.defense,
            magic_attack: player.magic_attack,
            magic_defense: player.magic_defense,
            agility: player.agility,
            luck: player.luck
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

  def add_experience
    player = Player.find(params[:id])
    exp_amount = params[:experience].to_i

    if exp_amount <= 0
      render json: {
        success: false,
        message: "経験値は1以上で入力してください"
      }, status: :unprocessable_entity
      return
    end

    level_ups = player.gain_experience(exp_amount)

    render json: {
      success: true,
      message: level_ups ? "#{exp_amount}の経験値を獲得し、#{level_ups}レベル上がりました！" : "#{exp_amount}の経験値を獲得しました",
      current_stats: {
        level: player.level,
        experience: player.experience,
        skill_points: player.skill_points,
        exp_to_next_level: player.exp_to_next_level,
        level_progress: player.level_progress,
        stats: {
          hp: player.hp,
          max_hp: player.max_hp,
          mp: player.mp,
          max_mp: player.max_mp,
          attack: player.attack,
          defense: player.defense,
          magic_attack: player.magic_attack,
          magic_defense: player.magic_defense,
          agility: player.agility,
          luck: player.luck
        }
      }
    }
  end

  private

  def development_test_mode?
    Rails.env.development? && params[:test] == "true"
  end
end
