class Api::V1::CharactersController < ApplicationController
  before_action :find_character, only: [ :show, :switch_job, :add_experience ]

  def show
    render json: {
      id: @character.id,
      name: @character.name,
      gold: @character.gold,
      current_job: @character.current_job_class ? {
        job_id: @character.current_job_class.job_class.id,
        job_name: @character.current_job_name,
        level: @character.level,
        experience: @character.experience,
        skill_points: @character.skill_points,
        exp_to_next_level: @character.exp_to_next_level,
        level_progress: @character.level_progress,
        stats: {
          hp: @character.hp,
          max_hp: @character.max_hp,
          mp: @character.mp,
          max_mp: @character.max_mp,
          attack: @character.attack,
          defense: @character.defense,
          magic_attack: @character.magic_attack,
          magic_defense: @character.magic_defense,
          agility: @character.agility,
          luck: @character.luck
        }
      } : nil,
      job_classes: @character.character_job_classes.includes(:job_class).map do |pjc|
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
          is_current: @character.current_job_class_id == pjc.id,
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
      end
    }
  end

  def switch_job
    job_class = JobClass.find(params[:job_class_id])

    begin
      @character.switch_job!(job_class)

      render json: {
        success: true,
        message: "職業を#{job_class.name}に変更しました",
        current_job: {
          job_id: job_class.id,
          job_name: @character.current_job_name,
          level: @character.level,
          experience: @character.experience,
          skill_points: @character.skill_points,
          exp_to_next_level: @character.exp_to_next_level,
          level_progress: @character.level_progress,
          stats: {
            hp: @character.hp,
            max_hp: @character.max_hp,
            mp: @character.mp,
            max_mp: @character.max_mp,
            attack: @character.attack,
            defense: @character.defense,
            magic_attack: @character.magic_attack,
            magic_defense: @character.magic_defense,
            agility: @character.agility,
            luck: @character.luck
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
    exp_amount = params[:experience].to_i

    if exp_amount <= 0
      render json: {
        success: false,
        message: "経験値は1以上で入力してください"
      }, status: :unprocessable_entity
      return
    end

    level_ups = @character.gain_experience(exp_amount)

    render json: {
      success: true,
      message: level_ups ? "#{exp_amount}の経験値を獲得し、#{level_ups}レベル上がりました！" : "#{exp_amount}の経験値を獲得しました",
      level_ups: level_ups || 0,
      current_stats: {
        level: @character.level,
        experience: @character.experience,
        skill_points: @character.skill_points,
        exp_to_next_level: @character.exp_to_next_level,
        level_progress: @character.level_progress,
        stats: {
          hp: @character.hp,
          max_hp: @character.max_hp,
          mp: @character.mp,
          max_mp: @character.max_mp,
          attack: @character.attack,
          defense: @character.defense,
          magic_attack: @character.magic_attack,
          magic_defense: @character.magic_defense,
          agility: @character.agility,
          luck: @character.luck
        }
      }
    }
  end

  private

  def find_character
    @character = Character.includes(:current_character_job_class, character_job_classes: :job_class)
                    .find(params[:id])
  end
end
