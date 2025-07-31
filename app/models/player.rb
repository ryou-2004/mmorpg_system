class Player < ApplicationRecord
  belongs_to :user
  has_many :player_job_classes, dependent: :destroy
  has_many :job_classes, through: :player_job_classes
  has_many :player_items, dependent: :destroy
  has_many :items, through: :player_items
  has_one :player_stat, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 20 }
  validates :name, uniqueness: { scope: :user_id }
  validates :gold, presence: true, numericality: { greater_than_or_equal_to: 0 }

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

  def add_gold!(amount)
    update!(gold: gold + amount)
  end

  def spend_gold!(amount)
    return false if gold < amount
    update!(gold: gold - amount)
    true
  end

  def unlock_job!(job_class)
    player_job_classes.find_or_create_by!(job_class: job_class) do |pjc|
      pjc.unlocked_at = Time.current
    end
  end
end
