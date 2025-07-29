class Admin::DashboardController < ApplicationController
  include Authenticable

  def show
    dashboard_data = {
      stats: {
        total_admin_users: AdminUser.count,
        active_admin_users: AdminUser.active.count,
        inactive_admin_users: AdminUser.inactive.count,
        total_permissions: AdminPermission.count,
        active_permissions: AdminPermission.active.count
      },
      recent_logins: recent_admin_logins,
      system_info: {
        rails_version: Rails.version,
        ruby_version: RUBY_VERSION,
        environment: Rails.env,
        database_adapter: ActiveRecord::Base.connection.adapter_name
      },
      current_admin: {
        id: current_user.id,
        name: current_user.name,
        role: current_user.role,
        last_login_at: current_user.last_login_at,
        permissions_count: current_user.admin_permissions.active.count
      }
    }

    render json: dashboard_data
  end

  private

  def recent_admin_logins
    AdminUser.active
             .where.not(last_login_at: nil)
             .order(last_login_at: :desc)
             .limit(10)
             .select(:id, :name, :email, :role, :last_login_at)
             .map do |admin|
      {
        id: admin.id,
        name: admin.name,
        email: admin.email,
        role: admin.role,
        last_login_at: admin.last_login_at
      }
    end
  end
end