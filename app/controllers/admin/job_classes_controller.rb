class Admin::JobClassesController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    job_classes = JobClass.includes(:player_job_classes)
                         .order(:job_type, :id)

    render json: {
      data: job_classes.map do |job_class|
        {
          id: job_class.id,
          name: job_class.name,
          job_type: job_class.job_type,
          max_level: job_class.max_level,
          experience_multiplier: job_class.exp_multiplier,
          description: job_class.description,
          created_at: job_class.created_at,
          players_count: job_class.player_job_classes.count
        }
      end
    }
  end
end
