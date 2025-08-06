class Admin::BattleLogsController < ApplicationController
  before_action :set_battle_log, only: [:show, :destroy]
  before_action :set_battle, only: [:index, :create]
  before_action :handle_development_test_mode

  def index
    @battle_logs = @battle.battle_logs.includes(:attacker, :defender)
                          .where(filter_params)
                          .order(order_params)
                          .limit(100)

    render json: {
      battle_logs: @battle_logs.map { |log| battle_log_detail_json(log) },
      battle: {
        id: @battle.id,
        battle_type: @battle.battle_type,
        location: @battle.location,
        status: @battle.status
      },
      stats: battle_log_stats(@battle_logs),
      meta: {
        battle_id: @battle.id,
        total_count: @battle.battle_logs.count,
        filtered_count: @battle_logs.size
      }
    }
  end

  def show
    render json: {
      battle_log: battle_log_detail_json(@battle_log),
      battle_info: {
        id: @battle_log.battle.id,
        battle_type: @battle_log.battle.battle_type,
        location: @battle_log.battle.location
      },
      calculation_details: @battle_log.calculation_details_data
    }
  end

  def create
    @battle_log = @battle.battle_logs.build(battle_log_params)
    @battle_log.occurred_at = Time.current
    
    if @battle_log.save
      update_battle_totals(@battle)
      render json: { 
        battle_log: battle_log_detail_json(@battle_log),
        message: '戦闘ログを記録しました'
      }, status: :created
    else
      render json: { errors: @battle_log.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    battle_id = @battle_log.battle_id
    @battle_log.destroy
    battle = Battle.find(battle_id)
    update_battle_totals(battle)
    render json: { message: '戦闘ログを削除しました' }
  end

  private

  def set_battle_log
    @battle_log = BattleLog.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: '戦闘ログが見つかりません' }, status: :not_found
  end

  def set_battle
    @battle = Battle.find(params[:battle_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: '戦闘が見つかりません' }, status: :not_found
  end

  def battle_log_params
    params.require(:battle_log).permit(:attacker_id, :defender_id, :action_type, 
                                      :damage_value, :critical_hit, :skill_name, 
                                      :calculation_details)
  end

  def filter_params
    filters = {}
    filters[:action_type] = params[:action_type] if params[:action_type].present?
    filters[:critical_hit] = params[:critical_hit] if params[:critical_hit].present?
    filters[:attacker_id] = params[:attacker_id] if params[:attacker_id].present?
    filters[:defender_id] = params[:defender_id] if params[:defender_id].present?
    filters
  end

  def order_params
    case params[:sort]
    when 'damage'
      { damage_value: :desc }
    when 'action_type'
      [:action_type, :occurred_at]
    when 'critical'
      { critical_hit: :desc }
    else
      { occurred_at: :asc }
    end
  end

  def battle_log_detail_json(log)
    {
      id: log.id,
      battle_id: log.battle_id,
      attacker: log.attacker ? {
        id: log.attacker.id,
        name: log.attacker.name,
        job_class: log.attacker.current_character_job_class&.job_class&.name
      } : nil,
      defender: log.defender ? {
        id: log.defender.id,
        name: log.defender.name,
        job_class: log.defender.current_character_job_class&.job_class&.name
      } : nil,
      action_type: log.action_type,
      action_type_name: log.action_type.humanize,
      action_summary: log.action_summary,
      damage_value: log.damage_value,
      critical_hit: log.critical_hit,
      skill_name: log.skill_name,
      occurred_at: log.occurred_at,
      is_effective: log.is_effective?,
      calculation_details: log.calculation_details_data,
      created_at: log.created_at
    }
  end

  def battle_log_stats(logs)
    return {} if logs.empty?
    
    {
      total_logs: logs.count,
      damage_events: logs.with_damage.count,
      critical_hits: logs.critical_hits.count,
      critical_rate: (logs.critical_hits.count.to_f / logs.count * 100).round(2),
      total_damage: logs.sum(:damage_value),
      avg_damage: logs.with_damage.average(:damage_value)&.round(2) || 0,
      max_damage: logs.maximum(:damage_value) || 0,
      action_breakdown: logs.group(:action_type).count,
      timeline_stats: {
        first_action: logs.minimum(:occurred_at),
        last_action: logs.maximum(:occurred_at),
        duration_minutes: logs.any? ? ((logs.maximum(:occurred_at) - logs.minimum(:occurred_at)) / 1.minute).round(2) : 0
      }
    }
  end

  def update_battle_totals(battle)
    total_damage = battle.battle_logs.sum(:damage_value)
    participants_count = battle.battle_participants.count
    
    battle.update_columns(
      total_damage: total_damage,
      participants_count: participants_count
    )
  end

  def handle_development_test_mode
    return unless Rails.env.development? && params[:test] == 'true'
    
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
  end
end
