class Admin::CharactersController < Admin::BaseController

  def index
    characters = Character.includes(current_character_job_class: :job_class)
                   .order(created_at: :desc)

    render json: {
      data: characters.map do |character|
        {
          id: character.id,
          name: character.name,
          gold: character.gold,
          active: character.active,
          current_job_name: character.current_character_job_class ? character.current_job_name : "未設定",
          current_job_level: character.current_character_job_class ? character.level : 0
        }
      end
    }
  end

  def show
    character = Character.includes(:user, :character_warehouses, current_character_job_class: :job_class, character_job_classes: :job_class)
                   .find(params[:id])

    # パフォーマンス最適化されたカウントメソッドを使用

    render json: {
      id: character.id,
      name: character.name,
      gold: character.gold || 0,
      active: character.active,
      created_at: character.created_at,
      last_login_at: character.last_login_at,
      current_job_class: character.current_character_job_class ? {
        id: character.current_character_job_class.id,
        level: character.level,
        experience: character.experience,
        skill_points: character.skill_points,
        job_class: {
          id: character.current_character_job_class.job_class.id,
          name: character.current_job_name,
          job_type: character.current_character_job_class.job_class.job_type
        }
      } : nil,
      user: {
        id: character.user.id,
        name: character.user.name,
        email: character.user.email
      },
      job_classes: character.character_job_classes.includes(:job_class).map do |cjc|
        {
          id: cjc.id,
          job_class: {
            id: cjc.job_class.id,
            name: cjc.job_class.name,
            job_type: cjc.job_class.job_type,
            max_level: cjc.job_class.max_level
          },
          level: cjc.level,
          experience: cjc.experience,
          skill_points: cjc.skill_points,
          exp_to_next_level: cjc.exp_to_next_level,
          level_progress: cjc.level_progress,
          unlocked_at: cjc.unlocked_at,
          is_current: character.current_character_job_class_id == cjc.id,
          stats: {
            hp: cjc.hp,
            max_hp: cjc.max_hp,
            mp: cjc.mp,
            max_mp: cjc.max_mp,
            attack: cjc.attack,
            defense: cjc.defense,
            magic_attack: cjc.magic_attack,
            magic_defense: cjc.magic_defense,
            agility: cjc.agility,
            luck: cjc.luck
          }
        }
      end,
      warehouses: character.character_warehouses.map do |warehouse|
        {
          id: warehouse.id,
          name: warehouse.name,
          max_slots: warehouse.max_slots,
          used_slots: character.warehouse_usage_by_id[warehouse.id] || 0
        }
      end,
      inventory_count: character.inventory_count,
      equipped_count: character.equipped_count
    }
  end

  def switch_job
    character = Character.find(params[:id])
    job_class = JobClass.find(params[:job_class_id])

    begin
      character.switch_job!(job_class)

      render json: {
        success: true,
        message: "職業を#{job_class.name}に変更しました",
        current_job: {
          job_name: character.current_job_name,
          level: character.level,
          experience: character.experience,
          skill_points: character.skill_points,
          stats: {
            hp: character.hp,
            max_hp: character.max_hp,
            mp: character.mp,
            max_mp: character.max_mp,
            attack: character.attack,
            defense: character.defense,
            magic_attack: character.magic_attack,
            magic_defense: character.magic_defense,
            agility: character.agility,
            luck: character.luck
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
    character = Character.find(params[:id])
    exp_amount = params[:experience].to_i

    if exp_amount <= 0
      render json: {
        success: false,
        message: "経験値は1以上で入力してください"
      }, status: :unprocessable_entity
      return
    end

    level_ups = character.gain_experience(exp_amount)

    render json: {
      success: true,
      message: level_ups ? "#{exp_amount}の経験値を獲得し、#{level_ups}レベル上がりました！" : "#{exp_amount}の経験値を獲得しました",
      current_stats: {
        level: character.level,
        experience: character.experience,
        skill_points: character.skill_points,
        exp_to_next_level: character.exp_to_next_level,
        level_progress: character.level_progress,
        stats: {
          hp: character.hp,
          max_hp: character.max_hp,
          mp: character.mp,
          max_mp: character.max_mp,
          attack: character.attack,
          defense: character.defense,
          magic_attack: character.magic_attack,
          magic_defense: character.magic_defense,
          agility: character.agility,
          luck: character.luck
        }
      }
    }
  end

  private

end
