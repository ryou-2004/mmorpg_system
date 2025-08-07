class Admin::BattlesController < ApplicationController
  before_action :set_battle, only: [ :show, :update, :destroy, :statistics, :end_battle ]
  before_action :handle_development_test_mode

  def index
    @battles = Battle.includes(:winner, :battle_participants, :characters)
                    .where(filter_params)
                    .order(order_params)
                    .limit(50)

    battles_json = @battles.map { |battle| battle_json(battle) }

    render json: {
      battles: battles_json,
      stats: battle_stats(@battles),
      meta: {
        total_count: Battle.count,
        filtered_count: @battles.size,
        page: 1,
        per_page: 50
      }
    }
  end

  def show
    render json: {
      battle: battle_detail_json(@battle),
      participants: @battle.battle_participants.includes(:character).map { |p| participant_json(p) },
      recent_logs: @battle.battle_logs.includes(:attacker, :defender).chronological.limit(20).map { |log| battle_log_json(log) },
      stats: battle_detail_stats(@battle)
    }
  end

  def create
    @battle = Battle.new(battle_params)
    @battle.status = :ongoing
    @battle.start_time = Time.current

    if @battle.save
      render json: {
        battle: battle_json(@battle),
        message: "戦闘を開始しました"
      }, status: :created
    else
      render json: { errors: @battle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @battle.update(battle_params)
      render json: {
        battle: battle_json(@battle),
        message: "戦闘情報を更新しました"
      }
    else
      render json: { errors: @battle.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    battle_name = "#{@battle.battle_type.humanize} Battle ##{@battle.id}"
    @battle.destroy
    render json: { message: "#{battle_name}を削除しました" }
  end

  def statistics
    render json: {
      battle: battle_json(@battle),
      statistics: detailed_battle_statistics(@battle),
      damage_analysis: damage_analysis(@battle),
      timeline_data: timeline_data(@battle)
    }
  end

  def end_battle
    if @battle.ongoing?
      winner = determine_winner(@battle)
      @battle.update!(
        status: :completed,
        end_time: Time.current,
        winner: winner,
        battle_duration: ((Time.current - @battle.start_time) / 1.minute).round
      )
      render json: {
        battle: battle_json(@battle),
        message: "戦闘を終了しました"
      }
    else
      render json: { error: "進行中の戦闘ではありません" }, status: :unprocessable_entity
    end
  end

  private

  def set_battle
    @battle = Battle.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "戦闘が見つかりません" }, status: :not_found
  end

  def battle_params
    params.require(:battle).permit(:battle_type, :location, :difficulty_level, :winner_id)
  end

  def filter_params
    filters = {}
    filters[:battle_type] = params[:battle_type] if params[:battle_type].present?
    filters[:status] = params[:status] if params[:status].present?
    filters[:location] = params[:location] if params[:location].present?
    filters
  end

  def order_params
    case params[:sort]
    when "start_time"
      { start_time: :desc }
    when "duration"
      { battle_duration: :desc }
    when "damage"
      { total_damage: :desc }
    else
      { start_time: :desc }
    end
  end

  def battle_json(battle)
    {
      id: battle.id,
      battle_type: battle.battle_type,
      battle_type_name: battle.battle_type.humanize,
      status: battle.status,
      status_name: battle.status.humanize,
      location: battle.location,
      difficulty_level: battle.difficulty_level,
      start_time: battle.start_time,
      end_time: battle.end_time,
      duration: battle.duration,
      participants_count: battle.participants_count,
      total_damage: battle.total_damage,
      winner: battle.winner ? { id: battle.winner.id, name: battle.winner.name } : nil,
      created_at: battle.created_at,
      updated_at: battle.updated_at
    }
  end

  def battle_detail_json(battle)
    battle_json(battle).merge({
      total_actions: battle.total_actions,
      average_damage_per_action: battle.total_actions > 0 ? (battle.total_damage.to_f / battle.total_actions).round(2) : 0
    })
  end

  def participant_json(participant)
    {
      id: participant.id,
      character: {
        id: participant.character.id,
        name: participant.character.name,
        job_class: participant.character.current_character_job_class&.job_class&.name
      },
      role: participant.role,
      role_name: participant.role.humanize,
      damage_dealt: participant.damage_dealt,
      damage_received: participant.damage_received,
      actions_taken: participant.actions_taken,
      survived: participant.survived,
      damage_ratio: participant.damage_ratio,
      effectiveness_score: participant.effectiveness_score
    }
  end

  def battle_log_json(log)
    {
      id: log.id,
      action_type: log.action_type,
      action_summary: log.action_summary,
      damage_value: log.damage_value,
      critical_hit: log.critical_hit,
      skill_name: log.skill_name,
      occurred_at: log.occurred_at,
      is_effective: log.is_effective?
    }
  end

  def battle_stats(battles)
    {
      total_battles: battles.count,
      by_type: battles.group(:battle_type).count,
      by_status: battles.group(:status).count,
      avg_duration: battles.where.not(battle_duration: nil).average(:battle_duration)&.round(2) || 0,
      total_damage: battles.sum(:total_damage),
      avg_participants: (battles.sum(:participants_count).to_f / [ battles.count, 1 ].max).round(2)
    }
  end

  def battle_detail_stats(battle)
    logs = battle.battle_logs
    {
      total_actions: logs.count,
      damage_actions: logs.with_damage.count,
      critical_hits: logs.critical_hits.count,
      critical_rate: logs.count > 0 ? (logs.critical_hits.count.to_f / logs.count * 100).round(2) : 0,
      action_breakdown: logs.group(:action_type).count
    }
  end

  def detailed_battle_statistics(battle)
    participants = battle.battle_participants
    {
      participants_stats: {
        total: participants.count,
        survivors: participants.survivors.count,
        casualties: participants.casualties.count,
        survival_rate: participants.count > 0 ? (participants.survivors.count.to_f / participants.count * 100).round(2) : 0
      },
      damage_stats: {
        total_damage: participants.sum(:damage_dealt),
        avg_damage_dealt: participants.average(:damage_dealt)&.round(2) || 0,
        max_damage_dealt: participants.maximum(:damage_dealt) || 0,
        total_damage_received: participants.sum(:damage_received),
        avg_damage_received: participants.average(:damage_received)&.round(2) || 0
      }
    }
  end

  def damage_analysis(battle)
    logs = battle.battle_logs.with_damage
    return {} if logs.empty?

    damage_values = logs.pluck(:damage_value)
    {
      total_damage_events: logs.count,
      avg_damage: (damage_values.sum.to_f / damage_values.size).round(2),
      max_damage: damage_values.max,
      min_damage: damage_values.min,
      critical_damage: logs.critical_hits.average(:damage_value)&.round(2) || 0,
      normal_damage: logs.where(critical_hit: false).average(:damage_value)&.round(2) || 0
    }
  end

  def timeline_data(battle)
    battle.battle_logs.chronological.limit(50).map do |log|
      {
        time: ((log.occurred_at - battle.start_time) / 1.minute).round(2),
        action: log.action_summary,
        damage: log.damage_value,
        critical: log.critical_hit
      }
    end
  end

  def determine_winner(battle)
    survivors = battle.battle_participants.survivors.includes(:character)
    return nil if survivors.empty?

    survivors.max_by(&:effectiveness_score)&.character
  end

  def handle_development_test_mode
    return unless Rails.env.development? && params[:test] == "true"

    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
