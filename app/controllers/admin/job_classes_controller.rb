class Admin::JobClassesController < ApplicationController
  before_action :authenticate_admin_user!, unless: :development_test_mode?

  def index
    job_classes = JobClass.left_joins(:character_job_classes)
                         .select("job_classes.*, COUNT(character_job_classes.id) as characters_count")
                         .group("job_classes.id")
                         .order(:id)

    render json: {
      data: job_classes.map do |job_class|
        {
          id: job_class.id,
          name: job_class.name,
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
          },
          created_at: job_class.created_at,
          characters_count: job_class.characters_count
        }
      end
    }
  end

  def show
    job_class = JobClass.find(params[:id])

    # 職業に関連するキャラクターの統計データを取得
    character_job_classes = job_class.character_job_classes.includes(:character)

    # レベル分布を計算
    level_distribution = character_job_classes.group(:level).count

    # トップレベルキャラクター
    top_characters = character_job_classes.order(level: :desc, experience: :desc)
                                   .limit(10)
                                   .map do |pjc|
      {
        player_name: pjc.player.name,
        level: pjc.level,
        experience: pjc.experience,
        skill_points: pjc.skill_points,
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
      },
      stats: {
        total_characters: character_job_classes.count,
        average_level: character_job_classes.average(:level)&.round(2) || 0,
        max_level_reached: character_job_classes.maximum(:level) || 1,
        level_distribution: level_distribution
      },
      top_characters: top_characters
    }
  end

  def update
    job_class = JobClass.find(params[:id])

    if job_class.update(job_class_params)
      render json: {
        success: true,
        message: "職業データが更新されました",
        data: {
          id: job_class.id,
          name: job_class.name,
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
      }
    else
      render json: {
        success: false,
        message: "更新に失敗しました",
        errors: job_class.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def job_class_params
    params.require(:job_class).permit(
      :name, :description, :job_type, :max_level, :exp_multiplier,
      :base_hp, :base_mp, :base_attack, :base_defense,
      :base_magic_attack, :base_magic_defense, :base_agility, :base_luck,
      :hp_multiplier, :mp_multiplier, :attack_multiplier, :defense_multiplier,
      :magic_attack_multiplier, :magic_defense_multiplier, :agility_multiplier, :luck_multiplier
    )
  end

  def development_test_mode?
    Rails.env.development? && params[:test] == "true"
  end
end
