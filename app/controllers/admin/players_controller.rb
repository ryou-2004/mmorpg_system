class Admin::PlayersController < ApplicationController
  before_action :authenticate_admin_user!
  
  def index
    players = Player.includes(:user, player_job_classes: :job_class)
                   .order(created_at: :desc)

    render json: {
      data: players.map do |player|
        {
          id: player.id,
          name: player.name,
          level: player.level,
          created_at: player.created_at,
          last_login_at: player.last_login_at,
          user: {
            id: player.user.id,
            username: player.user.username
          },
          job_classes: player.player_job_classes.map do |pjc|
            {
              id: pjc.job_class.id,
              name: pjc.job_class.name,
              job_type: pjc.job_class.job_type,
              current_level: pjc.current_level,
              current_experience: pjc.current_experience
            }
          end
        }
      end
    }
  end
end