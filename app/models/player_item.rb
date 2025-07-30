class PlayerItem < ApplicationRecord
  belongs_to :player
  belongs_to :item

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :enchantment_level, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :equipped, -> { where(equipped: true) }
  scope :unequipped, -> { where(equipped: false) }
  scope :by_item_type, ->(type) { joins(:item).where(items: { item_type: type }) }

  def can_equip?
    item.equipment? && !equipped?
  end

  def can_stack_with?(other_player_item)
    return false unless item == other_player_item.item
    return false unless item.stackable?
    return false if equipped? || other_player_item.equipped?
    
    enchantment_level == other_player_item.enchantment_level
  end

  def total_quantity_available
    return quantity unless item.stackable?
    
    player.player_items
          .where(item: item, enchantment_level: enchantment_level, equipped: false)
          .sum(:quantity)
  end

  def durability_percentage
    return 100 if max_durability.nil? || max_durability.zero?
    return 0 if durability.nil? || durability.zero?
    
    (durability.to_f / max_durability * 100).round
  end
end
