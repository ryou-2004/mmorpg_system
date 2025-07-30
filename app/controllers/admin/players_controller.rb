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
          gold: player.gold,
          active: player.active,
          created_at: player.created_at,
          last_login_at: player.last_login_at,
          user: {
            id: player.user.id,
            name: player.user.name,
            email: player.user.email
          },
          job_classes: player.player_job_classes.map do |pjc|
            {
              id: pjc.job_class.id,
              name: pjc.job_class.name,
              job_type: pjc.job_class.job_type,
              level: pjc.level,
              experience: pjc.experience,
              unlocked_at: pjc.unlocked_at
            }
          end
        }
      end
    }
  end
end
