class Admin::QuestsController < ApplicationController
  before_action :set_quest, only: [ :show, :update, :destroy ]
  before_action :handle_development_test_mode

  def index
    @quests = Quest.includes(:prerequisite_quest, :dependent_quests, :quest_category)
                   .where(filter_params)
                   .order(order_params)
                   .limit(limit_params)
                   .offset(offset_params)

    render json: {
      quests: @quests.map { |quest| quest_json(quest) },
      meta: {
        total_count: Quest.where(filter_params).count,
        page: page_params,
        per_page: limit_params,
        total_pages: (Quest.where(filter_params).count.to_f / limit_params).ceil
      }
    }
  end

  def show
    render json: {
      quest: quest_detail_json(@quest),
      character_stats: quest_character_stats(@quest),
      prerequisites: prerequisite_chain(@quest),
      dependents: @quest.dependent_quests.active.ordered.map { |q| quest_json(q) }
    }
  end

  def create
    @quest = Quest.new(quest_params)

    if @quest.save
      add_item_rewards if params[:quest][:item_rewards].present?
      render json: { quest: quest_detail_json(@quest) }, status: :created
    else
      render json: { errors: @quest.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @quest.update(quest_params)
      update_item_rewards if params[:quest][:item_rewards].present?
      render json: { quest: quest_detail_json(@quest) }
    else
      render json: { errors: @quest.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @quest.character_quests.exists?
      render json: { error: "キャラクターが進行中のため削除できません" }, status: :unprocessable_entity
    else
      @quest.destroy
      render json: { message: "クエストを削除しました" }
    end
  end

  private

  def set_quest
    @quest = Quest.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "クエストが見つかりません" }, status: :not_found
  end

  def quest_params
    params.require(:quest).permit(:title, :description, :quest_type, :level_requirement,
                                  :experience_reward, :gold_reward, :skill_point_reward,
                                  :status, :active, :prerequisite_quest_id, :display_order, 
                                  :quest_category_id, :display_number)
  end

  def filter_params
    filters = {}
    filters[:quest_type] = params[:quest_type] if params[:quest_type].present?
    filters[:status] = params[:status] if params[:status].present?
    filters[:active] = params[:active] if params[:active].present?
    filters[:quest_category_id] = params[:quest_category_id] if params[:quest_category_id].present?
    filters
  end

  def order_params
    case params[:sort]
    when "level"
      :level_requirement
    when "reward"
      :experience_reward
    when "type"
      :quest_type
    when "created"
      :created_at
    else
      [ :display_order, :id ]
    end
  end

  def limit_params
    [ (params[:per_page] || 20).to_i, 100 ].min
  end

  def offset_params
    (page_params - 1) * limit_params
  end

  def page_params
    [ params[:page].to_i, 1 ].max
  end

  def quest_json(quest)
    {
      id: quest.id,
      title: quest.title,
      display_title: quest.display_title,
      description: quest.description,
      quest_type: quest.quest_type,
      quest_type_name: quest.quest_type_name,
      display_number: quest.display_number,
      has_display_number: quest.has_display_number?,
      level_requirement: quest.level_requirement,
      experience_reward: quest.experience_reward,
      gold_reward: quest.gold_reward,
      skill_point_reward: quest.skill_point_reward,
      status: quest.status,
      status_name: quest.status_name,
      active: quest.active,
      display_order: quest.display_order,
      prerequisite_quest_id: quest.prerequisite_quest_id,
      prerequisite_quest_title: quest.prerequisite_quest&.title,
      quest_category_id: quest.quest_category_id,
      quest_category_name: quest.quest_category&.name,
      created_at: quest.created_at,
      updated_at: quest.updated_at
    }
  end

  def quest_detail_json(quest)
    quest_json(quest).merge({
      item_rewards: quest.item_rewards || [],
      total_rewards: quest.total_rewards,
      dependent_quests_count: quest.dependent_quests.count
    })
  end

  def quest_character_stats(quest)
    character_quests = quest.character_quests.includes(:character)

    {
      total_characters: character_quests.count,
      completed_count: character_quests.completed.count,
      in_progress_count: character_quests.active.count,
      completion_rate: character_quests.count > 0 ?
        (character_quests.completed.count.to_f / character_quests.count * 100).round(2) : 0,
      average_duration: calculate_average_duration(character_quests.completed)
    }
  end

  def prerequisite_chain(quest)
    chain = []
    current_quest = quest.prerequisite_quest

    while current_quest
      chain.unshift(quest_json(current_quest))
      current_quest = current_quest.prerequisite_quest
      break if chain.length > 10
    end

    chain
  end

  def add_item_rewards
    return unless params[:quest][:item_rewards].is_a?(Array)

    params[:quest][:item_rewards].each do |reward|
      @quest.add_item_reward(reward[:type], reward[:item_id], reward[:quantity])
    end
  end

  def update_item_rewards
    @quest.update!(item_rewards: params[:quest][:item_rewards])
  end

  def calculate_average_duration(completed_quests)
    durations = completed_quests.map(&:duration).compact
    return 0 if durations.empty?

    total_seconds = durations.sum
    average_seconds = total_seconds / durations.length
    (average_seconds / 3600).round(2)
  end

  def handle_development_test_mode
    return unless Rails.env.development? && params[:test] == "true"

    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
