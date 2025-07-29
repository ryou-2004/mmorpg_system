class Admin::UsersController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    users = User.includes(:players)
                .select(:id, :name, :email, :created_at, :last_login_at)
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
          is_active: user.last_login_at&.>(30.days.ago)
        }
      end
    }
  end
end
