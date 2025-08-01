class User < ApplicationRecord
  has_many :characters, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end

  def update_last_login!
    update!(last_login_at: Time.current)
  end
end
