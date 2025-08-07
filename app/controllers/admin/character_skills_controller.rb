class Admin::CharacterSkillsController < ApplicationController
  before_action :set_character
  before_action :set_character_job_class, only: [ :show, :invest_points, :reset_points ]

  def index
    character_job_classes = @character.character_job_classes.includes(
      :job_class,
      character_skills: [ :skill_line, :job_class ]
    )

    render json: {
      character: {
        id: @character.id,
        name: @character.name
      },
      character_job_classes: character_job_classes.map do |cjc|
        {
          id: cjc.id,
          job_class: {
            id: cjc.job_class.id,
            name: cjc.job_class.name,
            job_type: cjc.job_class.job_type
          },
          level: cjc.level,
          total_skill_points: cjc.total_skill_points,
          available_skill_points: cjc.available_skill_points,
          used_skill_points: cjc.used_skill_points,
          skill_investments: cjc.character_skills.map do |cs|
            {
              id: cs.id,
              skill_line: {
                id: cs.skill_line.id,
                name: cs.skill_line.name,
                skill_line_type: cs.skill_line.skill_line_type
              },
              points_invested: cs.points_invested,
              unlocked_nodes: cs.unlocked_nodes.map do |node|
                {
                  id: node.id,
                  name: node.name,
                  node_type: node.node_type,
                  effects: node.effects_data
                }
              end
            }
          end
        }
      end
    }
  end

  def show
    available_skill_lines = @character_job_class.available_skill_lines.includes(:skill_nodes)

    render json: {
      character: {
        id: @character.id,
        name: @character.name
      },
      character_job_class: {
        id: @character_job_class.id,
        job_class: {
          id: @character_job_class.job_class.id,
          name: @character_job_class.job_class.name,
          job_type: @character_job_class.job_class.job_type
        },
        level: @character_job_class.level,
        total_skill_points: @character_job_class.total_skill_points,
        available_skill_points: @character_job_class.available_skill_points,
        used_skill_points: @character_job_class.used_skill_points
      },
      available_skill_lines: available_skill_lines.map do |skill_line|
        invested_points = @character_job_class.skill_investment_for_line(skill_line)

        {
          id: skill_line.id,
          name: skill_line.name,
          description: skill_line.description,
          skill_line_type: skill_line.skill_line_type,
          points_invested: invested_points,
          skill_nodes: skill_line.skill_nodes.active.order(:points_required).map do |node|
            is_unlocked = invested_points >= node.points_required

            {
              id: node.id,
              name: node.name,
              description: node.description,
              node_type: node.node_type,
              points_required: node.points_required,
              effects: node.effects_data,
              position_x: node.position_x,
              position_y: node.position_y,
              is_unlocked: is_unlocked
            }
          end
        }
      end
    }
  end

  def invest_points
    skill_line = SkillLine.find(params[:skill_line_id])
    points = params[:points].to_i

    if @character_job_class.invest_skill_points!(skill_line, points)
      render json: {
        message: "スキルポイントが投資されました",
        character_job_class: {
          available_skill_points: @character_job_class.available_skill_points,
          used_skill_points: @character_job_class.used_skill_points
        },
        skill_investment: {
          skill_line_id: skill_line.id,
          points_invested: @character_job_class.skill_investment_for_line(skill_line)
        }
      }
    else
      render json: {
        errors: [ "スキルポイントの投資に失敗しました" ]
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "スキルラインが見つかりません" }, status: :not_found
  end

  def reset_points
    skill_line = SkillLine.find(params[:skill_line_id])

    character_skill = @character.character_skills.find_by(
      job_class: @character_job_class.job_class,
      skill_line: skill_line
    )

    if character_skill
      character_skill.update!(points_invested: 0)
      render json: {
        message: "スキルポイントがリセットされました",
        character_job_class: {
          available_skill_points: @character_job_class.available_skill_points,
          used_skill_points: @character_job_class.used_skill_points
        }
      }
    else
      render json: {
        errors: [ "スキル投資情報が見つかりません" ]
      }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "スキルラインが見つかりません" }, status: :not_found
  end

  def add_skill_points
    additional_points = params[:additional_points].to_i
    reason = params[:reason] || "管理者による手動調整"

    if additional_points <= 0
      render json: { errors: [ "追加ポイントは1以上である必要があります" ] }, status: :unprocessable_entity
      return
    end

    @character_job_class.increment!(:total_skill_points, additional_points)

    render json: {
      message: "スキルポイントが追加されました",
      character_job_class: {
        id: @character_job_class.id,
        total_skill_points: @character_job_class.total_skill_points,
        available_skill_points: @character_job_class.available_skill_points,
        used_skill_points: @character_job_class.used_skill_points
      },
      adjustment: {
        additional_points: additional_points,
        reason: reason
      }
    }
  end

  private

  def set_character
    @character = Character.find(params[:character_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "キャラクターが見つかりません" }, status: :not_found
  end

  def set_character_job_class
    @character_job_class = @character.character_job_classes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "キャラクターの職業情報が見つかりません" }, status: :not_found
  end
end
