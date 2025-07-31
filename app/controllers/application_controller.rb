class ApplicationController < ActionController::API
  protected

  def authenticate_admin_user!
    token = extract_token_from_header
    return render_unauthorized unless token

    decoded_token = AdminUser.decode_token(token)
    return render_unauthorized unless decoded_token

    @current_admin_user = find_admin_user_from_token(decoded_token)
    return render_unauthorized unless @current_admin_user&.active?

    @current_admin_user.update_last_login!
  end

  def current_admin_user
    @current_admin_user
  end

  private

  def extract_token_from_header
    auth_header = request.headers["Authorization"]
    return nil unless auth_header&.start_with?("Bearer ")

    auth_header.split(" ").last
  end

  def find_admin_user_from_token(decoded_token)
    user_type = decoded_token["user_type"]
    user_id = decoded_token["user_id"]

    return nil unless user_type == "AdminUser"
    AdminUser.find_by(id: user_id)
  end

  def render_unauthorized
    render json: { error: "認証が必要です" }, status: :unauthorized
  end

  def development_test_mode?
    Rails.env.test? || ((Rails.env.development? || Rails.env.test?) && params[:test] == "true")
  end
end
