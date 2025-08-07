class Continent < ApplicationRecord
  has_many :regions, dependent: :destroy
  has_many :enemy_spawns, through: :regions
  has_many :enemies, through: :enemy_spawns
  
  validates :name, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :grid_width, :grid_height, presence: true, 
    numericality: { greater_than: 0, less_than_or_equal_to: 26 }
  validates :world_position_x, :world_position_y, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  
  scope :active, -> { where(active: true) }
  scope :by_world_position, ->(x, y) { where(world_position_x: x, world_position_y: y) }
  
  def total_regions
    grid_width * grid_height
  end
  
  def grid_coordinates
    coordinates = []
    ('A'..'Z').first(grid_width).each_with_index do |col, x|
      (1..grid_height).each do |row|
        coordinates << { x: x, y: row - 1, coordinate: "#{col}#{row}" }
      end
    end
    coordinates
  end
  
  def region_at(grid_x, grid_y)
    regions.find_by(grid_x: grid_x, grid_y: grid_y)
  end
  
  def world_coordinate
    "(#{world_position_x}, #{world_position_y})"
  end
end
