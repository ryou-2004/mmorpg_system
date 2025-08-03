class Admin::JobComparisonsController < Admin::BaseController

  def index
    job_ids = params[:job_ids] || []
    job_ids = job_ids.split(",") if job_ids.is_a?(String)
    level = (params[:level] || 20).to_i

    if job_ids.empty?
      render json: { error: I18n.t('messages.errors.select_job_classes_to_compare') }, status: :unprocessable_entity
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
      render json: { error: I18n.t('messages.errors.select_job_classes_to_compare') }, status: :unprocessable_entity
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
    {
      id: job_class.id,
      name: job_class.name,
      job_type: job_class.job_type,
      stats: {
        hp: job_class.hp_at_level(level),
        max_hp: job_class.hp_at_level(level),
        mp: job_class.mp_at_level(level),
        max_mp: job_class.mp_at_level(level),
        attack: job_class.attack_at_level(level),
        defense: job_class.defense_at_level(level),
        magic_attack: job_class.magic_attack_at_level(level),
        magic_defense: job_class.magic_defense_at_level(level),
        agility: job_class.agility_at_level(level),
        luck: job_class.luck_at_level(level)
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
    {
      level: level,
      hp: job_class.hp_at_level(level),
      max_hp: job_class.hp_at_level(level),
      mp: job_class.mp_at_level(level),
      max_mp: job_class.mp_at_level(level),
      attack: job_class.attack_at_level(level),
      defense: job_class.defense_at_level(level),
      magic_attack: job_class.magic_attack_at_level(level),
      magic_defense: job_class.magic_defense_at_level(level),
      agility: job_class.agility_at_level(level),
      luck: job_class.luck_at_level(level)
    }
  end

end
