class Admin::SkillNodesController < ApplicationController
  before_action :set_skill_line
  before_action :set_skill_node, only: [:show, :update, :destroy]

  def index
    skill_nodes = @skill_line.skill_nodes.active.ordered

    render json: {
      skill_nodes: skill_nodes.map do |node|
        format_skill_node(node)
      end,
      skill_line: {
        id: @skill_line.id,
        name: @skill_line.name,
        skill_line_type: @skill_line.skill_line_type
      },
      meta: {
        total_count: skill_nodes.count
      }
    }
  end

  def show
    render json: {
      skill_node: format_skill_node(@skill_node)
    }
  end

  def create
    skill_node = @skill_line.skill_nodes.build(skill_node_params)

    if skill_node.save
      render json: {
        skill_node: format_skill_node(skill_node),
        message: "スキルノードが作成されました"
      }, status: :created
    else
      render json: {
        errors: skill_node.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @skill_node.update(skill_node_params)
      render json: {
        skill_node: format_skill_node(@skill_node),
        message: "スキルノードが更新されました"
      }
    else
      render json: {
        errors: @skill_node.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @skill_node.update!(active: false)
    render json: {
      message: "スキルノードが無効化されました"
    }
  rescue => e
    render json: {
      errors: [e.message]
    }, status: :unprocessable_entity
  end

  private

  def set_skill_line
    @skill_line = SkillLine.find(params[:skill_line_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "スキルラインが見つかりません" }, status: :not_found
  end

  def set_skill_node
    @skill_node = @skill_line.skill_nodes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "スキルノードが見つかりません" }, status: :not_found
  end

  def skill_node_params
    params.require(:skill_node).permit(:name, :description, :node_type, :points_required, 
                                       :display_order, :active, effects: {})
  end

  def format_skill_node(skill_node)
    {
      id: skill_node.id,
      name: skill_node.name,
      description: skill_node.description,
      node_type: skill_node.node_type,
      node_type_name: I18n.t("skill_nodes.types.#{skill_node.node_type}", default: skill_node.node_type),
      points_required: skill_node.points_required,
      effects: skill_node.effects_data,
      display_order: skill_node.display_order,
      active: skill_node.active,
      skill_line_id: skill_node.skill_line_id,
      created_at: skill_node.created_at,
      updated_at: skill_node.updated_at
    }
  end
end