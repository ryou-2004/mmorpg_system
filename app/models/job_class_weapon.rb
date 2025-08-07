class JobClassWeapon < ApplicationRecord
  belongs_to :job_class

  validates :weapon_category, presence: true, inclusion: { in: Weapon.weapon_categories.keys }
  validates :unlock_level, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }
  validates :job_class_id, uniqueness: { scope: :weapon_category }

  scope :active, -> { where(active: true) }
  scope :by_unlock_level, -> { order(:unlock_level) }

  def weapon_category_name
    I18n.t("weapons.categories.#{weapon_category}", default: weapon_category)
  end
end
