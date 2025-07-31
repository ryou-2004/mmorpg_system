class Api::V1::JobClassesController < ApplicationController
  def index
    job_classes = JobClass.active.order(:id)

    render json: {
      data: job_classes.map do |job_class|
        {
          id: job_class.id,
          name: job_class.name,
          description: job_class.description,
          job_type: job_class.job_type,
          max_level: job_class.max_level,
          experience_multiplier: job_class.exp_multiplier,
          base_stats: {
            hp: job_class.base_hp,
            mp: job_class.base_mp,
            attack: job_class.base_attack,
            defense: job_class.base_defense,
            magic_attack: job_class.base_magic_attack,
            magic_defense: job_class.base_magic_defense,
            agility: job_class.base_agility,
            luck: job_class.base_luck
          },
          multipliers: {
            hp: job_class.hp_multiplier,
            mp: job_class.mp_multiplier,
            attack: job_class.attack_multiplier,
            defense: job_class.defense_multiplier,
            magic_attack: job_class.magic_attack_multiplier,
            magic_defense: job_class.magic_defense_multiplier,
            agility: job_class.agility_multiplier,
            luck: job_class.luck_multiplier
          }
        }
      end
    }
  end

  def show
    job_class = JobClass.find(params[:id])

    render json: {
      id: job_class.id,
      name: job_class.name,
      description: job_class.description,
      job_type: job_class.job_type,
      max_level: job_class.max_level,
      experience_multiplier: job_class.exp_multiplier,
      base_stats: {
        hp: job_class.base_hp,
        mp: job_class.base_mp,
        attack: job_class.base_attack,
        defense: job_class.base_defense,
        magic_attack: job_class.base_magic_attack,
        magic_defense: job_class.base_magic_defense,
        agility: job_class.base_agility,
        luck: job_class.base_luck
      },
      multipliers: {
        hp: job_class.hp_multiplier,
        mp: job_class.mp_multiplier,
        attack: job_class.attack_multiplier,
        defense: job_class.defense_multiplier,
        magic_attack: job_class.magic_attack_multiplier,
        magic_defense: job_class.magic_defense_multiplier,
        agility: job_class.agility_multiplier,
        luck: job_class.luck_multiplier
      }
    }
  end

  # 指定レベルでのステータス計算（プレビュー用）
  def calculate_stats
    job_class = JobClass.find(params[:id])
    level = params[:level].to_i

    if level < 1 || level > job_class.max_level
      render json: {
        success: false,
        message: "レベルは1から#{job_class.max_level}の間で指定してください"
      }, status: :unprocessable_entity
      return
    end

    # 仮のPlayerJobClassインスタンスを作成してステータス計算
    temp_pjc = PlayerJobClass.new(
      job_class: job_class,
      level: level,
      experience: 0,
      skill_points: 0,
      unlocked_at: Time.current
    )

    render json: {
      level: level,
      job_class: {
        id: job_class.id,
        name: job_class.name
      },
      stats: {
        hp: temp_pjc.hp,
        max_hp: temp_pjc.max_hp,
        mp: temp_pjc.mp,
        max_mp: temp_pjc.max_mp,
        attack: temp_pjc.attack,
        defense: temp_pjc.defense,
        magic_attack: temp_pjc.magic_attack,
        magic_defense: temp_pjc.magic_defense,
        agility: temp_pjc.agility,
        luck: temp_pjc.luck
      }
    }
  end
end
