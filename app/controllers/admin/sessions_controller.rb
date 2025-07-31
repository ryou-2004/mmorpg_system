class Admin::SessionsController < ApplicationController
  def show
    authenticate_admin_user!
    render json: {
      admin_user: {
        id: current_admin_user.id,
        email: current_admin_user.email,
        name: current_admin_user.name,
        role: current_admin_user.role,
        last_login_at: current_admin_user.last_login_at
      }
    }
  end

  def create
    admin_user = AdminUser.find_by(email: session_params[:email])

    if admin_user&.authenticate(session_params[:password]) && admin_user.active?
      token = admin_user.generate_token
      admin_user.update_last_login!

      render json: {
        token: token,
        admin_user: {
          id: admin_user.id,
          email: admin_user.email,
          name: admin_user.name,
          role: admin_user.role
        }
      }, status: :created
    else
      render json: { error: "メールアドレスまたはパスワードが正しくありません" }, status: :unauthorized
    end
  end

  def destroy
    render json: { message: "ログアウトしました" }
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
