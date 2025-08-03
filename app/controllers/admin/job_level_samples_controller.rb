class Admin::JobLevelSamplesController < Admin::BaseController

  def index
    level = (params[:level] || 20).to_i
    level = [ [ level, 1 ].max, 100 ].min

    job_classes = JobClass.active.order(:job_type, :id)

    stats_data = job_classes.map do |job_class|
      build_job_stats_data(job_class, level)
    end

    rankings = build_rankings(stats_data)

    render json: {
      level: level,
      job_stats: stats_data,
      rankings: rankings
    }
  end

  def show
    level = params[:id].to_i
    level = [ [ level, 1 ].max, 100 ].min

    job_classes = JobClass.active.order(:job_type, :id)

    stats_data = job_classes.map do |job_class|
      build_job_stats_data(job_class, level)
    end

    rankings = build_rankings(stats_data)

    render json: {
      level: level,
      job_stats: stats_data,
      rankings: rankings
    }
  end

  private

  def build_job_stats_data(job_class, level)
    {
      id: job_class.id,
      name: job_class.name,
      job_type: job_class.job_type,
      max_level: job_class.max_level,
      level: level,
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

  def build_rankings(stats_data)
    rankings = {}

    %i[hp mp attack defense magic_attack magic_defense agility luck].each do |stat_type|
      top_jobs = stats_data.sort_by { |data| -data[:stats][stat_type] }.first(3)
      rankings[stat_type] = top_jobs.map { |job| { name: job[:name], value: job[:stats][stat_type] } }
    end

    rankings
  end

end
