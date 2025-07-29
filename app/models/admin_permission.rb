class AdminPermission < ApplicationRecord
  belongs_to :admin_user
  belongs_to :granted_by, class_name: "AdminUser"

  ACTIONS = %w[index show create update destroy manage].freeze

  validates :resource_type, presence: true, inclusion: { in: :available_resource_types }
  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :granted_at, presence: true

  scope :active, -> { where(active: true) }
  scope :for_resource, ->(resource_type, resource_id = nil) {
    where(resource_type: resource_type, resource_id: resource_id)
  }
  scope :with_action, ->(action) { where(action: action) }

  def self.available_resource_types
    ApplicationRecord.descendants.map(&:name).sort
  end

  def revoke!
    update!(active: false)
  end

  def grant!
    update!(active: true)
  end

  def applies_to_resource?(resource_type, resource_id = nil)
    return false unless self.resource_type == resource_type
    return true if self.resource_id.nil?
    self.resource_id == resource_id
  end

  private

  def available_resource_types
    self.class.available_resource_types
  end
end
