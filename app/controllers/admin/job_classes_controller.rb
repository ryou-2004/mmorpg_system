class Admin::JobClassesController < ApplicationController
  before_action :authenticate_admin_user!, unless: :development_test_mode?

  def index
    job_classes = JobClass.left_joins(:player_job_classes)
                         .select('job_classes.*, COUNT(player_job_classes.id) as players_count')
                         .group('job_classes.id')
                         .order(:job_type, :id)

    render json: {
      data: job_classes.map do |job_class|
        {
          id: job_class.id,
          name: job_class.name,
          job_type: job_class.job_type,
          max_level: job_class.max_level,
          experience_multiplier: job_class.exp_multiplier,
          created_at: job_class.created_at,
          players_count: job_class.players_count
        }
      end
    }
  end

  private

  def development_test_mode?
    Rails.env.development? && params[:test] == 'true'
  end
end
