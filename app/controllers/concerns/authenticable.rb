module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  private

  def authenticate_request
    token = extract_token_from_header
    return render_unauthorized unless token

    decoded_token = AdminUser.decode_token(token)
    return render_unauthorized unless decoded_token

    @current_user = find_user_from_token(decoded_token)
    return render_unauthorized unless @current_user&.active?

    @current_user.update_last_login!
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header&.start_with?('Bearer ')
    
    auth_header.split(' ').last
  end

  def find_user_from_token(decoded_token)
    user_type = decoded_token['user_type']
    user_id = decoded_token['user_id']
    
    case user_type
    when 'AdminUser'
      AdminUser.find_by(id: user_id)
    else
      nil
    end
  end

  def render_unauthorized
    render json: { error: '認証が必要です' }, status: :unauthorized
  end

  def require_permission(action, resource_type, resource_id = nil)
    unless current_user.can?(action.to_s, resource_type, resource_id)
      render json: { error: '権限がありません' }, status: :forbidden
    end
  end
end