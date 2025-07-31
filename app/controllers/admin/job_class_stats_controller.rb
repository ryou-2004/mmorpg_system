class Admin::JobClassStatsController < ApplicationController
  before_action :authenticate_admin_user!, unless: :development_test_mode?

  # GET /admin/job_class_stats
  # 全職業のレベル別ステータス一覧
  def index
    job_classes = JobClass.active.order(:job_type, :id)

    # レベル範囲設定（クエリパラメータで指定可能）
    if params[:levels].present?
      levels = params[:levels].split(',').map(&:to_i).select { |l| l > 0 && l <= 100 }
    else
      # デフォルト: 基本的なマイルストーンレベル
      levels = [ 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 ]
    end

    render json: {
      levels: levels,
      job_classes: job_classes.map do |job_class|
        {
          id: job_class.id,
          name: job_class.name,
          job_type: job_class.job_type,
          max_level: job_class.max_level,
          base_stats: build_base_stats(job_class),
          multipliers: build_multipliers(job_class),
          stats_by_level: levels.map do |level|
            build_level_stats(job_class, level)
          end
        }
      end
    }
  end

  # GET /admin/job_class_stats/:id
  # 特定職業の成長チャート
  def show
    job_class = JobClass.find(params[:id])
    max_level = [ job_class.max_level, 50 ].min # 最大50レベルまで表示

    levels = (1..max_level).step(max_level > 25 ? 2 : 1).to_a
    levels << max_level unless levels.include?(max_level)

    growth_data = levels.map do |level|
      build_level_stats(job_class, level)
    end

    render json: {
      job_class: {
        id: job_class.id,
        name: job_class.name,
        job_type: job_class.job_type,
        max_level: job_class.max_level
      },
      growth_data: growth_data,
      stat_analysis: {
        hp_growth_per_level: calculate_average_growth(growth_data, :hp),
        mp_growth_per_level: calculate_average_growth(growth_data, :mp),
        attack_growth_per_level: calculate_average_growth(growth_data, :attack),
        defense_growth_per_level: calculate_average_growth(growth_data, :defense),
        magic_attack_growth_per_level: calculate_average_growth(growth_data, :magic_attack),
        magic_defense_growth_per_level: calculate_average_growth(growth_data, :magic_defense),
        agility_growth_per_level: calculate_average_growth(growth_data, :agility),
        luck_growth_per_level: calculate_average_growth(growth_data, :luck)
      }
    }
  end

  private

  def build_base_stats(job_class)
    {
      hp: job_class.base_hp,
      mp: job_class.base_mp,
      attack: job_class.base_attack,
      defense: job_class.base_defense,
      magic_attack: job_class.base_magic_attack,
      magic_defense: job_class.base_magic_defense,
      agility: job_class.base_agility,
      luck: job_class.base_luck
    }
  end

  def build_multipliers(job_class)
    {
      hp: job_class.hp_multiplier,
      mp: job_class.mp_multiplier,
      attack: job_class.attack_multiplier,
      defense: job_class.defense_multiplier,
      magic_attack: job_class.magic_attack_multiplier,
      magic_defense: job_class.magic_defense_multiplier,
      agility: job_class.agility_multiplier,
      luck: job_class.luck_multiplier
    }
  end

  def build_level_stats(job_class, level)
    temp_pjc = PlayerJobClass.new(
      job_class: job_class,
      level: level,
      experience: 0,
      skill_points: 0,
      unlocked_at: Time.current
    )

    {
      level: level,
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
  end

  def calculate_average_growth(growth_data, stat_key)
    return 0 if growth_data.length < 2

    first_stat = growth_data.first[stat_key]
    last_stat = growth_data.last[stat_key]
    level_diff = growth_data.last[:level] - growth_data.first[:level]

    return 0 if level_diff == 0

    ((last_stat - first_stat).to_f / level_diff).round(2)
  end

  def development_test_mode?
    Rails.env.development? && params[:test] == "true"
  end
end
