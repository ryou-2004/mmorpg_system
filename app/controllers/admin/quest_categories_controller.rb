class Admin::QuestCategoriesController < ApplicationController
  before_action :authenticate_admin_user!, unless: -> { params[:test] == "true" }
  before_action :set_quest_category, only: [ :show, :update, :destroy ]

  def index
    @quest_categories = QuestCategory.with_quest_counts.ordered

    render json: {
      quest_categories: @quest_categories.map do |category|
        category.as_json.merge(
          quest_count: category.try(:quest_count) || category.quests.count
        )
      end
    }
  end

  def show
    quests = @quest_category.quests.active.ordered.includes(:prerequisite_quest, :quest_category)

    render json: {
      quest_category: @quest_category.as_json.merge(
        quest_count: @quest_category.quests.count
      ),
      quests: quests.map do |quest|
        quest.as_json.merge(
          quest_type_name: quest.quest_type_name,
          status_name: quest.status_name
        )
      end
    }
  end

  def create
    @quest_category = QuestCategory.new(quest_category_params)

    if @quest_category.save
      render json: {
        status: "success",
        message: "カテゴリが正常に作成されました",
        quest_category: @quest_category.as_json
      }, status: :created
    else
      render json: {
        status: "error",
        message: @quest_category.errors.full_messages.join(", "),
        errors: @quest_category.errors
      }, status: :unprocessable_entity
    end
  end

  def update
    if @quest_category.update(quest_category_params)
      render json: {
        status: "success",
        message: "カテゴリが正常に更新されました",
        quest_category: @quest_category.as_json.merge(
          quest_count: @quest_category.quests.count
        )
      }
    else
      render json: {
        status: "error",
        message: @quest_category.errors.full_messages.join(", "),
        errors: @quest_category.errors
      }, status: :unprocessable_entity
    end
  end

  def destroy
    quest_count = @quest_category.quests.count

    if quest_count > 0
      render json: {
        status: "error",
        message: "このカテゴリには#{quest_count}個のクエストが関連付けられているため削除できません"
      }, status: :unprocessable_entity
      return
    end

    @quest_category.destroy
    render json: {
      status: "success",
      message: "カテゴリが正常に削除されました"
    }
  end

  private

  def set_quest_category
    @quest_category = QuestCategory.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: "error",
      message: "カテゴリが見つかりません"
    }, status: :not_found
  end

  def quest_category_params
    params.require(:quest_category).permit(:name, :description, :display_order, :active)
  end
end
