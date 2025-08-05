class Admin::SkillLinesController < ApplicationController
  before_action :set_skill_line, only: [:show, :update, :destroy]

  def index
    skill_lines = SkillLine.includes(:skill_nodes, :job_classes)
                          .active

    skill_lines = skill_lines.where(skill_line_type: params[:skill_line_type]) if params[:skill_line_type].present?
    skill_lines = skill_lines.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?

    render json: {
      skill_lines: skill_lines.map do |skill_line|
        {
          id: skill_line.id,
          name: skill_line.name,
          description: skill_line.description,
          skill_line_type: skill_line.skill_line_type,
          skill_line_type_name: I18n.t("skill_lines.types.#{skill_line.skill_line_type}", default: skill_line.skill_line_type),
          nodes_count: skill_line.skill_nodes.active.count,
          job_classes_count: skill_line.job_classes.active.count,
          active: skill_line.active,
          created_at: skill_line.created_at,
          updated_at: skill_line.updated_at
        }
      end,
      meta: {
        total_count: skill_lines.count
      }
    }
  end

  def show
    render json: {
      skill_line: {
        id: @skill_line.id,
        name: @skill_line.name,
        description: @skill_line.description,
        skill_line_type: @skill_line.skill_line_type,
        skill_line_type_name: I18n.t("skill_lines.types.#{@skill_line.skill_line_type}", default: @skill_line.skill_line_type),
        active: @skill_line.active,
        skill_nodes: @skill_line.skill_nodes.active.ordered.map do |node|
          {
            id: node.id,
            name: node.name,
            description: node.description,
            node_type: node.node_type,
            node_type_name: I18n.t("skill_nodes.types.#{node.node_type}", default: node.node_type),
            points_required: node.points_required,
            effects: node.effects_data,
            display_order: node.display_order,
            active: node.active
          }
        end,
        job_classes: @skill_line.job_class_skill_lines.includes(:job_class).map do |jcsl|
          {
            id: jcsl.job_class.id,
            name: jcsl.job_class.name,
            job_type: jcsl.job_class.job_type,
            job_type_name: jcsl.job_class.job_type_name,
            unlock_level: jcsl.unlock_level
          }
        end,
        created_at: @skill_line.created_at,
        updated_at: @skill_line.updated_at
      }
    }
  end

  def create
    skill_line = SkillLine.new(skill_line_params)

    if skill_line.save
      render json: {
        skill_line: format_skill_line(skill_line),
        message: "スキルラインが作成されました"
      }, status: :created
    else
      render json: {
        errors: skill_line.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @skill_line.update(skill_line_params)
      render json: {
        skill_line: format_skill_line(@skill_line),
        message: "スキルラインが更新されました"
      }
    else
      render json: {
        errors: @skill_line.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @skill_line.update!(active: false)
    render json: {
      message: "スキルラインが無効化されました"
    }
  rescue => e
    render json: {
      errors: [e.message]
    }, status: :unprocessable_entity
  end

  private

  def set_skill_line
    @skill_line = SkillLine.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "スキルラインが見つかりません" }, status: :not_found
  end

  def skill_line_params
    params.require(:skill_line).permit(:name, :description, :skill_line_type, :active)
  end

  def format_skill_line(skill_line)
    {
      id: skill_line.id,
      name: skill_line.name,
      description: skill_line.description,
      skill_line_type: skill_line.skill_line_type,
      skill_line_type_name: I18n.t("skill_lines.types.#{skill_line.skill_line_type}", default: skill_line.skill_line_type),
      active: skill_line.active,
      created_at: skill_line.created_at,
      updated_at: skill_line.updated_at
    }
  end
end