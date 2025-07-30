class Admin::UsersController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    users = User.includes(:players)
                .select(:id, :name, :email, :created_at, :last_login_at, :active)
                .order(created_at: :desc)

    render json: {
      data: users.map do |user|
        {
          id: user.id,
          username: user.name,
          email: user.email,
          created_at: user.created_at,
          last_login_at: user.last_login_at,
          player_count: user.players.count,
          is_active: user.active
        }
      end
    }
  end

  def show
    user = User.includes(players: { player_job_classes: :job_class })
               .find(params[:id])

    render json: {
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        active: user.active,
        created_at: user.created_at,
        last_login_at: user.last_login_at,
        players: user.players.map do |player|
          {
            id: player.id,
            name: player.name,
            gold: player.gold,
            active: player.active,
            created_at: player.created_at,
            last_login_at: player.last_login_at,
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
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'ユーザーが見つかりません' }, status: :not_found
  end
end
