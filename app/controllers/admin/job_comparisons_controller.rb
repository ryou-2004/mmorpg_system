class Admin::JobComparisonsController < ApplicationController
  before_action :authenticate_admin_user!, unless: :development_test_mode?

  def index
    job_ids = params[:job_ids] || []
    job_ids = job_ids.split(",") if job_ids.is_a?(String)
    level = (params[:level] || 20).to_i

    if job_ids.empty?
      render json: { error: "比較する職業を選択してください" }, status: :unprocessable_entity
      return
    end

    job_classes = JobClass.where(id: job_ids).order(:job_type, :id)

    render json: {
      level: level,
      comparison: job_classes.map do |job_class|
        build_comparison_data(job_class, level)
      end
    }
  end

  def create
    job_ids = params[:job_ids] || []
    job_ids = job_ids.split(",") if job_ids.is_a?(String)
    level = (params[:level] || 20).to_i
    comparison_type = params[:comparison_type] || "basic"

    if job_ids.empty?
      render json: { error: "比較する職業を選択してください" }, status: :unprocessable_entity
      return
    end

    case comparison_type
    when "multi_level"
      handle_multi_level_comparison(job_ids)
    else
      handle_basic_comparison(job_ids, level)
    end
  end

  private

  def handle_basic_comparison(job_ids, level)
    job_classes = JobClass.where(id: job_ids).order(:job_type, :id)

    render json: {
      level: level,
      comparison_type: "basic",
      comparison: job_classes.map do |job_class|
        build_comparison_data(job_class, level)
      end
    }
  end

  def handle_multi_level_comparison(job_ids)
    levels = params[:levels] || [ 1, 10, 20, 30, 40, 50 ]
    if levels.is_a?(String)
      levels = levels.split(",").map(&:to_i).select { |l| l > 0 && l <= 100 }
    else
      levels = levels.map(&:to_i).select { |l| l > 0 && l <= 100 }
    end

    job_classes = JobClass.where(id: job_ids).order(:job_type, :id)

    comparison_data = job_classes.map do |job_class|
      level_stats = levels.map do |level|
        next nil if level > job_class.max_level

        build_level_stats(job_class, level)
      end.compact

      {
        id: job_class.id,
        name: job_class.name,
        job_type: job_class.job_type,
        max_level: job_class.max_level,
        level_stats: level_stats
      }
    end

    render json: {
      levels: levels,
      comparison_type: "multi_level",
      job_comparison: comparison_data
    }
  end

  def build_comparison_data(job_class, level)
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

  def development_test_mode?
    Rails.env.development? && params[:test] == "true"
  end
end
