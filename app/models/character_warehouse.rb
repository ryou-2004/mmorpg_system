class CharacterWarehouse < ApplicationRecord
  belongs_to :character
  has_many :character_items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :max_slots, presence: true, numericality: { greater_than: 0 }

  after_initialize :set_default_name, if: :new_record?

  def available_slots
    max_slots - character_items.character_accessible.count
  end

  def full?
    available_slots <= 0
  end

  def has_available_slots?
    available_slots > 0
  end

  private

  def set_default_name
    warehouse_count = character&.character_warehouses&.count || 0
    self.name ||= case warehouse_count
    when 0 then "メイン倉庫"
    when 1 then "サブ倉庫"
    when 2 then "素材倉庫"
    else "倉庫#{warehouse_count + 1}"
    end
  end
end
