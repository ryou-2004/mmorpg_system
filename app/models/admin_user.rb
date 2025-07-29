class AdminUser < ApplicationRecord
  include JwtAuthenticable
  
  has_secure_password
  has_many :admin_permissions, dependent: :destroy
  has_many :granted_permissions, class_name: 'AdminPermission', foreign_key: 'granted_by_id'

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :role, presence: true, inclusion: { in: %w[super_admin admin moderator] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def super_admin?
    role == 'super_admin'
  end

  def admin?
    role == 'admin'
  end

  def moderator?
    role == 'moderator'
  end

  def update_last_login!
    update!(last_login_at: Time.current)
  end

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end

  def can?(action, resource_type, resource_id = nil)
    return true if super_admin?
    
    admin_permissions.active
                    .for_resource(resource_type, resource_id)
                    .with_action([action, 'manage'])
                    .exists? ||
    admin_permissions.active
                    .for_resource(resource_type, nil)
                    .with_action([action, 'manage'])
                    .exists?
  end

  def grant_permission!(resource_type, action, granted_by, resource_id = nil)
    admin_permissions.create!(
      resource_type: resource_type,
      resource_id: resource_id,
      action: action,
      granted_at: Time.current,
      granted_by: granted_by
    )
  end

  def revoke_permission!(resource_type, action, resource_id = nil)
    permission = admin_permissions.active
                                 .for_resource(resource_type, resource_id)
                                 .with_action(action)
                                 .first
    permission&.revoke!
  end
end
