class Admin::CharacterQuestsController < ApplicationController
  before_action :set_character_quest, only: [ :show, :update, :destroy, :complete, :abandon, :reset ]
  before_action :handle_development_test_mode

  def index
    @character_quests = CharacterQuest.includes(:character, :quest)
                                     .where(filter_params)
                                     .order(order_params)
                                     .limit(limit_params)
                                     .offset(offset_params)

    render json: {
      character_quests: @character_quests.map { |cq| character_quest_json(cq) },
      meta: {
        total_count: CharacterQuest.where(filter_params).count,
        page: page_params,
        per_page: limit_params,
        total_pages: (CharacterQuest.where(filter_params).count.to_f / limit_params).ceil
      },
      stats: quest_progress_stats
    }
  end

  def show
    render json: {
      character_quest: character_quest_detail_json(@character_quest),
      character: character_basic_info(@character_quest.character),
      quest: quest_basic_info(@character_quest.quest)
    }
  end

  def create
    character = Character.find(params[:character_quest][:character_id])
    quest = Quest.find(params[:character_quest][:quest_id])

    if character.character_quests.exists?(quest: quest)
      render json: { error: "既にこのクエストを受注しています" }, status: :unprocessable_entity
      return
    end

    unless quest_available_for_character?(quest, character)
      render json: { error: "クエストの前提条件を満たしていません" }, status: :unprocessable_entity
      return
    end

    @character_quest = CharacterQuest.new(
      character: character,
      quest: quest,
      status: "started",
      started_at: Time.current,
      progress: {}
    )

    if @character_quest.save
      render json: { character_quest: character_quest_detail_json(@character_quest) }, status: :created
    else
      render json: { errors: @character_quest.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @character_quest.update(character_quest_params)
      render json: { character_quest: character_quest_detail_json(@character_quest) }
    else
      render json: { errors: @character_quest.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def complete
    if @character_quest.active?
      @character_quest.update!(
        status: "completed",
        completed_at: Time.current,
        progress: @character_quest.progress.merge("completed" => true)
      )

      grant_rewards(@character_quest)
      render json: {
        character_quest: character_quest_detail_json(@character_quest),
        message: "クエストを完了しました"
      }
    else
      render json: { error: "進行中のクエストではありません" }, status: :unprocessable_entity
    end
  end

  def abandon
    if @character_quest.active?
      @character_quest.update!(
        status: "abandoned",
        progress: @character_quest.progress.merge("abandoned" => true, "abandoned_at" => Time.current)
      )

      render json: {
        character_quest: character_quest_detail_json(@character_quest),
        message: "クエストを放棄しました"
      }
    else
      render json: { error: "進行中のクエストではありません" }, status: :unprocessable_entity
    end
  end

  def reset
    @character_quest.update!(
      status: "started",
      started_at: Time.current,
      completed_at: nil,
      progress: {}
    )

    render json: {
      character_quest: character_quest_detail_json(@character_quest),
      message: "クエストをリセットしました"
    }
  end

  def destroy
    @character_quest.destroy
    render json: { message: "クエスト進行状況を削除しました" }
  end

  private

  def set_character_quest
    @character_quest = CharacterQuest.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "クエスト進行状況が見つかりません" }, status: :not_found
  end

  def character_quest_params
    params.require(:character_quest).permit(:status, progress: {})
  end

  def filter_params
    filters = {}
    filters[:character_id] = params[:character_id] if params[:character_id].present?
    filters[:quest_id] = params[:quest_id] if params[:quest_id].present?
    filters[:status] = params[:status] if params[:status].present?
    filters
  end

  def order_params
    case params[:sort]
    when "character"
      { characters: :name }
    when "quest"
      { quests: :title }
    when "started"
      :started_at
    when "completed"
      :completed_at
    else
      [ :started_at, :id ]
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

  def character_quest_json(character_quest)
    {
      id: character_quest.id,
      character_id: character_quest.character_id,
      character_name: character_quest.character.name,
      quest_id: character_quest.quest_id,
      quest_title: character_quest.quest.title,
      quest_type: character_quest.quest.quest_type,
      quest_type_name: character_quest.quest.quest_type_name,
      status: character_quest.status,
      status_name: character_quest.status_name,
      started_at: character_quest.started_at,
      completed_at: character_quest.completed_at,
      duration_hours: character_quest.duration ? (character_quest.duration / 3600).round(2) : nil,
      created_at: character_quest.created_at,
      updated_at: character_quest.updated_at
    }
  end

  def character_quest_detail_json(character_quest)
    character_quest_json(character_quest).merge({
      progress: character_quest.progress,
      quest_details: {
        description: character_quest.quest.description,
        level_requirement: character_quest.quest.level_requirement,
        rewards: character_quest.quest.total_rewards
      }
    })
  end

  def character_basic_info(character)
    {
      id: character.id,
      name: character.name,
      gold: character.gold,
      current_job: character.current_character_job_class&.job_class&.name,
      current_level: character.current_character_job_class&.level
    }
  end

  def quest_basic_info(quest)
    {
      id: quest.id,
      title: quest.title,
      quest_type: quest.quest_type,
      quest_type_name: quest.quest_type_name,
      level_requirement: quest.level_requirement,
      total_rewards: quest.total_rewards
    }
  end

  def quest_progress_stats
    {
      total_quests: CharacterQuest.count,
      completed: CharacterQuest.completed.count,
      in_progress: CharacterQuest.active.count,
      abandoned: CharacterQuest.where(status: "abandoned").count,
      completion_rate: CharacterQuest.count > 0 ?
        (CharacterQuest.completed.count.to_f / CharacterQuest.count * 100).round(2) : 0
    }
  end

  def quest_available_for_character?(quest, character)
    return false unless quest.active? && quest.status == "available"
    return false if character.current_character_job_class.level < quest.level_requirement

    if quest.prerequisite_quest_id
      prerequisite_completed = character.character_quests
                                       .completed
                                       .exists?(quest_id: quest.prerequisite_quest_id)
      return false unless prerequisite_completed
    end

    true
  end

  def grant_rewards(character_quest)
    quest = character_quest.quest
    character = character_quest.character
    current_job_class = character.current_character_job_class

    return unless current_job_class

    new_experience = current_job_class.experience + quest.experience_reward
    new_gold = character.gold + quest.gold_reward
    new_skill_points = current_job_class.skill_points + quest.skill_point_reward

    current_job_class.update!(experience: new_experience, skill_points: new_skill_points)
    character.update!(gold: new_gold)

    if quest.item_rewards.present?
      quest.item_rewards.each do |item_reward|
        grant_item_reward(character, item_reward)
      end
    end
  end

  def grant_item_reward(character, item_reward)
    case item_reward["type"]
    when "Item"
      item = Item.find_by(id: item_reward["item_id"])
      return unless item

      character.character_items.create!(
        item: item,
        quantity: item_reward["quantity"],
        location: "inventory",
        obtained_at: Time.current
      )
    end
  end

  def handle_development_test_mode
    return unless Rails.env.development? && params[:test] == "true"

    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
