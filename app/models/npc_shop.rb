class NpcShop < ApplicationRecord
  belongs_to :npc
  belongs_to :shop

  validates :npc_id, uniqueness: { scope: :shop_id }
end
