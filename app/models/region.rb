class Region < ApplicationRecord
  belongs_to :continent
  has_many :enemy_spawns, dependent: :destroy
  has_many :enemies, through: :enemy_spawns
  
  REGION_TYPES = %w[field dungeon town special].freeze
  TERRAIN_TYPES = %w[grassland forest mountain desert swamp cave volcano ocean lake river bridge ruins].freeze
  CLIMATES = %w[temperate cold hot humid dry].freeze
  ACCESSIBILITY_TYPES = %w[always quest_required item_required level_required].freeze
  
  validates :grid_x, presence: true, format: { with: /\A[A-Z]\z/ }
  validates :grid_y, presence: true, inclusion: { in: 1..99 }
  validates :name, presence: true
  validates :display_name, presence: true
  validates :region_type, presence: true, inclusion: { in: REGION_TYPES }
  validates :level_range_min, :level_range_max, presence: true,
    numericality: { greater_than: 0 }
  validates :accessibility, inclusion: { in: ACCESSIBILITY_TYPES }
  validate :level_range_validity
  validate :grid_position_within_continent_bounds
  
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(region_type: type) }
  scope :by_terrain, ->(terrain) { where(terrain_type: terrain) }
  scope :by_level_range, ->(level) { 
    where('level_range_min <= ? AND level_range_max >= ?', level, level) 
  }
  scope :by_grid, ->(x, y) { where(grid_x: x, grid_y: y) }
  scope :accessible, -> { where(accessibility: 'always') }
  
  def coordinate
    "#{grid_x}#{grid_y}"
  end
  
  def level_range_display
    if level_range_min == level_range_max
      "Lv.#{level_range_min}"
    else
      "Lv.#{level_range_min}-#{level_range_max}"
    end
  end
  
  def region_type_name
    case region_type
    when 'field' then 'フィールド'
    when 'dungeon' then 'ダンジョン'
    when 'town' then '街・村'
    when 'special' then '特殊エリア'
    else region_type
    end
  end
  
  def terrain_type_name
    case terrain_type
    when 'grassland' then '草原'
    when 'forest' then '森'
    when 'mountain' then '山'
    when 'desert' then '砂漠'
    when 'swamp' then '沼地'
    when 'cave' then '洞窟'
    when 'volcano' then '火山'
    when 'ocean' then '海'
    when 'lake' then '湖'
    when 'river' then '川'
    when 'bridge' then '橋'
    when 'ruins' then '遺跡'
    else terrain_type
    end
  end
  
  def climate_name
    case climate
    when 'temperate' then '温帯'
    when 'cold' then '寒冷'
    when 'hot' then '高温'
    when 'humid' then '多湿'
    when 'dry' then '乾燥'
    else climate
    end
  end
  
  def accessibility_name
    case accessibility
    when 'always' then '常時アクセス可能'
    when 'quest_required' then 'クエスト必須'
    when 'item_required' then 'アイテム必須'
    when 'level_required' then 'レベル制限'
    else accessibility
    end
  end
  
  def neighbors
    directions = [
      [-1, -1], [0, -1], [1, -1],  # 上
      [-1,  0],          [1,  0],  # 左右
      [-1,  1], [0,  1], [1,  1]   # 下
    ]
    
    current_x = grid_x.ord - 'A'.ord
    current_y = grid_y
    
    neighbors = []
    directions.each do |dx, dy|
      new_x = current_x + dx
      new_y = current_y + dy
      
      next if new_x < 0 || new_y < 1
      next if new_x >= continent.grid_width || new_y > continent.grid_height
      
      new_grid_x = (new_x + 'A'.ord).chr
      neighbor = continent.regions.find_by(grid_x: new_grid_x, grid_y: new_y)
      neighbors << neighbor if neighbor
    end
    
    neighbors
  end
  
  private
  
  def level_range_validity
    return unless level_range_min && level_range_max
    
    if level_range_min > level_range_max
      errors.add(:level_range_max, 'は最小レベルより大きい値を設定してください')
    end
  end
  
  def grid_position_within_continent_bounds
    return unless continent && grid_x && grid_y
    
    x_index = grid_x.ord - 'A'.ord
    if x_index >= continent.grid_width
      errors.add(:grid_x, "は大陸のグリッド幅(#{continent.grid_width})を超えています")
    end
    
    if grid_y > continent.grid_height
      errors.add(:grid_y, "は大陸のグリッド高さ(#{continent.grid_height})を超えています")
    end
  end
end
