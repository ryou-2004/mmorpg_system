class AdminUser < ApplicationRecord
  has_secure_password

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
end
