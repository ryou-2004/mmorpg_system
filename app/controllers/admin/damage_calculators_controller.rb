class Admin::DamageCalculatorsController < ApplicationController
  before_action :handle_development_test_mode

  def verify
    attacker_data = params.require(:attacker).permit(:attack, :magic_attack, :level, :job_class_id, :weapon_type)
    defender_data = params.require(:defender).permit(:defense, :magic_defense, :level, :job_class_id)
    skill_data = params.permit(:skill_name, :skill_type, :damage_multiplier, :critical_rate)

    calculation_result = perform_damage_calculation(attacker_data, defender_data, skill_data)
    historical_data = find_similar_battle_data(attacker_data, defender_data, skill_data)

    verification_result = {
      calculation: calculation_result,
      historical_average: historical_data[:average_damage],
      historical_range: historical_data[:damage_range],
      variance_percentage: calculate_variance(calculation_result[:expected_damage], historical_data[:average_damage]),
      samples_count: historical_data[:samples_count],
      is_balanced: balanced_assessment(calculation_result, historical_data)
    }

    render json: {
      verification: verification_result,
      recommendations: generate_balance_recommendations(verification_result),
      debug_info: calculation_result[:debug_info]
    }
  rescue ActionController::ParameterMissing => e
    render json: { error: "必要なパラメータが不足しています: #{e.param}" }, status: :bad_request
  end

  def simulate
    simulation_params = params.permit(:attacker_id, :defender_id, :rounds, :skill_name)
    rounds = [ simulation_params[:rounds].to_i, 1000 ].min.positive? ? simulation_params[:rounds].to_i : 100

    attacker = Character.find(simulation_params[:attacker_id])
    defender = Character.find(simulation_params[:defender_id])

    simulation_results = run_damage_simulation(attacker, defender, rounds, simulation_params[:skill_name])

    render json: {
      simulation: {
        rounds: rounds,
        attacker: character_combat_stats(attacker),
        defender: character_combat_stats(defender),
        skill_used: simulation_params[:skill_name]
      },
      results: simulation_results
    }
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "キャラクターが見つかりません" }, status: :not_found
  end

  def analyze
    analysis_params = params.permit(:battle_type, :date_range, :character_level_min, :character_level_max)

    damage_patterns = analyze_damage_patterns(analysis_params)
    balance_issues = identify_balance_issues(damage_patterns)

    render json: {
      analysis: {
        parameters: analysis_params,
        total_battles_analyzed: damage_patterns[:total_battles],
        date_range: damage_patterns[:date_range]
      },
      patterns: damage_patterns[:patterns],
      balance_assessment: balance_issues,
      recommendations: generate_system_recommendations(balance_issues)
    }
  end

  private

  def perform_damage_calculation(attacker, defender, skill)
    base_attack = attacker[:attack].to_i
    base_defense = defender[:defense].to_i
    skill_multiplier = skill[:damage_multiplier].to_f.positive? ? skill[:damage_multiplier].to_f : 1.0
    level_factor = [ attacker[:level].to_i, 1 ].max / 50.0

    raw_damage = (base_attack * skill_multiplier * level_factor) - (base_defense * 0.5)
    expected_damage = [ raw_damage, 1 ].max.round

    critical_rate = skill[:critical_rate].to_f.clamp(0.0, 1.0)
    critical_damage = (expected_damage * 1.5).round

    damage_range = {
      min: (expected_damage * 0.8).round,
      max: (expected_damage * 1.2).round,
      critical: critical_damage
    }

    {
      expected_damage: expected_damage,
      damage_range: damage_range,
      critical_rate: critical_rate,
      skill_multiplier: skill_multiplier,
      level_factor: level_factor,
      debug_info: {
        raw_damage: raw_damage,
        base_attack: base_attack,
        base_defense: base_defense,
        defense_reduction: base_defense * 0.5
      }
    }
  end

  def find_similar_battle_data(attacker, defender, skill)
    level_range = 5
    attacker_level = attacker[:level].to_i

    similar_logs = BattleLog
      .joins(:attacker, :defender)
      .where(action_type: determine_action_type(skill[:skill_type]))
      .where("damage_value > 0")
      .limit(1000)

    damage_values = similar_logs.pluck(:damage_value)

    if damage_values.any?
      {
        average_damage: (damage_values.sum.to_f / damage_values.size).round(2),
        damage_range: {
          min: damage_values.min,
          max: damage_values.max,
          median: calculate_median(damage_values)
        },
        samples_count: damage_values.size,
        critical_hits: similar_logs.where(critical_hit: true).count
      }
    else
      {
        average_damage: 0,
        damage_range: { min: 0, max: 0, median: 0 },
        samples_count: 0,
        critical_hits: 0
      }
    end
  end

  def run_damage_simulation(attacker, defender, rounds, skill_name)
    results = []
    total_damage = 0
    critical_count = 0

    attacker_stats = {
      attack: attacker.attack,
      magic_attack: attacker.magic_attack,
      level: attacker.current_character_job_class&.level || 1
    }

    defender_stats = {
      defense: defender.defense,
      magic_defense: defender.magic_defense,
      level: defender.current_character_job_class&.level || 1
    }

    skill_data = {
      skill_name: skill_name,
      skill_type: "physical",
      damage_multiplier: 1.0 + (rand * 0.4 - 0.2),
      critical_rate: 0.1
    }

    rounds.times do |i|
      calculation = perform_damage_calculation(attacker_stats, defender_stats, skill_data)
      is_critical = rand < calculation[:critical_rate]

      damage = if is_critical
                 calculation[:damage_range][:critical]
      else
                 rand(calculation[:damage_range][:min]..calculation[:damage_range][:max])
      end

      results << {
        round: i + 1,
        damage: damage,
        critical: is_critical,
        calculation_details: calculation[:debug_info]
      }

      total_damage += damage
      critical_count += 1 if is_critical
    end

    {
      individual_results: results.first(20),  # First 20 rounds for display
      summary: {
        total_rounds: rounds,
        total_damage: total_damage,
        average_damage: (total_damage.to_f / rounds).round(2),
        critical_hits: critical_count,
        critical_rate: (critical_count.to_f / rounds * 100).round(2),
        min_damage: results.map { |r| r[:damage] }.min,
        max_damage: results.map { |r| r[:damage] }.max
      }
    }
  end

  def analyze_damage_patterns(params)
    battles_query = Battle.includes(:battle_logs)

    # Filter by battle type
    battles_query = battles_query.where(battle_type: params[:battle_type]) if params[:battle_type].present?

    # Filter by date range
    if params[:date_range].present?
      case params[:date_range]
      when "last_week"
        battles_query = battles_query.where("start_time >= ?", 1.week.ago)
      when "last_month"
        battles_query = battles_query.where("start_time >= ?", 1.month.ago)
      end
    end

    battles = battles_query.limit(100)
    all_logs = battles.flat_map(&:battle_logs).select { |log| log.damage_value > 0 }

    patterns = {
      damage_distribution: calculate_damage_distribution(all_logs),
      action_type_analysis: analyze_action_types(all_logs),
      critical_hit_analysis: analyze_critical_hits(all_logs),
      time_based_patterns: analyze_time_patterns(all_logs)
    }

    {
      total_battles: battles.count,
      date_range: battles.any? ? {
        start: battles.minimum(:start_time),
        end: battles.maximum(:end_time)
      } : {},
      patterns: patterns
    }
  end

  def character_combat_stats(character)
    {
      id: character.id,
      name: character.name,
      level: character.current_character_job_class&.level || 1,
      job_class: character.current_character_job_class&.job_class&.name || "None",
      attack: character.attack,
      magic_attack: character.magic_attack,
      defense: character.defense,
      magic_defense: character.magic_defense,
      hp: character.hp,
      mp: character.mp
    }
  end

  def calculate_variance(expected, actual)
    return 0 if expected == 0
    (((actual - expected).abs.to_f / expected) * 100).round(2)
  end

  def balanced_assessment(calculation, historical)
    variance = calculate_variance(calculation[:expected_damage], historical[:average_damage])
    sample_size = historical[:samples_count]

    {
      is_balanced: variance <= 20 && sample_size >= 10,
      confidence_level: calculate_confidence_level(sample_size),
      variance_status: case variance
                       when 0..10 then "excellent"
                       when 11..20 then "good"
                       when 21..35 then "acceptable"
                       else "needs_adjustment"
                       end
    }
  end

  def generate_balance_recommendations(verification)
    recommendations = []

    if verification[:variance_percentage] > 30
      recommendations << {
        type: "damage_adjustment",
        priority: "high",
        description: "ダメージ計算式の見直しが必要です",
        suggested_change: "スキル倍率または基本攻撃力の調整"
      }
    end

    if verification[:samples_count] < 10
      recommendations << {
        type: "data_collection",
        priority: "medium",
        description: "より多くのデータサンプルが必要です",
        suggested_action: "テスト戦闘の実行"
      }
    end

    recommendations
  end

  def calculate_damage_distribution(logs)
    damage_values = logs.map(&:damage_value)
    return {} if damage_values.empty?

    {
      min: damage_values.min,
      max: damage_values.max,
      average: (damage_values.sum.to_f / damage_values.size).round(2),
      median: calculate_median(damage_values),
      std_deviation: calculate_std_deviation(damage_values)
    }
  end

  def calculate_median(values)
    sorted = values.sort
    mid = sorted.length / 2
    sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
  end

  def calculate_std_deviation(values)
    return 0 if values.length <= 1

    mean = values.sum.to_f / values.length
    variance = values.map { |v| (v - mean) ** 2 }.sum / (values.length - 1)
    Math.sqrt(variance).round(2)
  end

  def determine_action_type(skill_type)
    case skill_type&.downcase
    when "physical" then "physical_attack"
    when "magical" then "magical_attack"
    when "heal" then "heal"
    else "physical_attack"
    end
  end

  def analyze_action_types(logs)
    logs.group_by(&:action_type).transform_values do |type_logs|
      damage_values = type_logs.map(&:damage_value)
      {
        count: type_logs.size,
        avg_damage: damage_values.any? ? (damage_values.sum.to_f / damage_values.size).round(2) : 0,
        max_damage: damage_values.max || 0
      }
    end
  end

  def analyze_critical_hits(logs)
    critical_logs = logs.select(&:critical_hit)
    normal_logs = logs.reject(&:critical_hit)

    {
      total_attacks: logs.size,
      critical_hits: critical_logs.size,
      critical_rate: logs.any? ? (critical_logs.size.to_f / logs.size * 100).round(2) : 0,
      critical_avg_damage: critical_logs.any? ? (critical_logs.sum(&:damage_value).to_f / critical_logs.size).round(2) : 0,
      normal_avg_damage: normal_logs.any? ? (normal_logs.sum(&:damage_value).to_f / normal_logs.size).round(2) : 0
    }
  end

  def analyze_time_patterns(logs)
    return {} if logs.empty?

    time_groups = logs.group_by { |log| log.occurred_at.hour }

    time_groups.transform_values do |hour_logs|
      {
        action_count: hour_logs.size,
        avg_damage: (hour_logs.sum(&:damage_value).to_f / hour_logs.size).round(2)
      }
    end
  end

  def identify_balance_issues(patterns)
    issues = []

    damage_dist = patterns[:patterns][:damage_distribution]
    if damage_dist[:std_deviation] && damage_dist[:std_deviation] > damage_dist[:average] * 0.5
      issues << {
        type: "high_variance",
        severity: "medium",
        description: "ダメージの分散が大きすぎます"
      }
    end

    crit_analysis = patterns[:patterns][:critical_hit_analysis]
    if crit_analysis[:critical_rate] && (crit_analysis[:critical_rate] > 25 || crit_analysis[:critical_rate] < 5)
      issues << {
        type: "critical_rate_imbalance",
        severity: "high",
        description: "クリティカル率が適正範囲外です"
      }
    end

    issues
  end

  def generate_system_recommendations(balance_issues)
    balance_issues.map do |issue|
      case issue[:type]
      when "high_variance"
        {
          action: "damage_formula_adjustment",
          description: "ダメージ計算式の安定化",
          priority: issue[:severity]
        }
      when "critical_rate_imbalance"
        {
          action: "critical_rate_tuning",
          description: "クリティカル率の調整（目標: 10-20%）",
          priority: issue[:severity]
        }
      else
        {
          action: "further_analysis",
          description: "詳細な分析が必要",
          priority: "low"
        }
      end
    end
  end

  def calculate_confidence_level(sample_size)
    case sample_size
    when 0..9 then "low"
    when 10..49 then "medium"
    when 50..199 then "high"
    else "very_high"
    end
  end

  def handle_development_test_mode
    return unless Rails.env.development? && params[:test] == "true"

    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
