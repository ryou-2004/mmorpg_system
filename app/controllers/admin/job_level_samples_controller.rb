class Admin::JobLevelSamplesController < ApplicationController
  before_action :authenticate_admin_user!, unless: :development_test_mode?

  # GET /admin/job_level_samples
  # 全職業のレベル別ステータス一覧表示
  def index
    level = (params[:level] || 20).to_i
    level = [ [ level, 1 ].max, 100 ].min # 1-100の範囲に制限

    job_classes = JobClass.active.order(:job_type, :id)

    stats_data = job_classes.map do |job_class|
      build_job_stats_data(job_class, level)
    end

    # 各ステータスでのランキング情報も追加
    rankings = build_rankings(stats_data)

    render json: {
      level: level,
      job_stats: stats_data,
      rankings: rankings
    }
  end

  # GET /admin/job_level_samples/:level
  # 特定レベルでの全職業ステータス表示
  def show
    level = params[:id].to_i
    level = [ [ level, 1 ].max, 100 ].min # 1-100の範囲に制限

    job_classes = JobClass.active.order(:job_type, :id)

    stats_data = job_classes.map do |job_class|
      build_job_stats_data(job_class, level)
    end

    # 各ステータスでのランキング情報も追加
    rankings = build_rankings(stats_data)

    render json: {
      level: level,
      job_stats: stats_data,
      rankings: rankings
    }
  end

  private

  def build_job_stats_data(job_class, level)
    temp_pjc = PlayerJobClass.new(
      job_class: job_class,
      level: level,
      experience: 0,
      skill_points: 0,
      unlocked_at: Time.current
    )

    {
      id: job_class.id,
      name: job_class.name,
      job_type: job_class.job_type,
      max_level: job_class.max_level,
      level: level,
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

  def build_rankings(stats_data)
    rankings = {}

    %i[hp mp attack defense magic_attack magic_defense agility luck].each do |stat_type|
      top_jobs = stats_data.sort_by { |data| -data[:stats][stat_type] }.first(3)
      rankings[stat_type] = top_jobs.map { |job| { name: job[:name], value: job[:stats][stat_type] } }
    end

    rankings
  end

  def development_test_mode?
    Rails.env.development? && params[:test] == "true"
  end
end
