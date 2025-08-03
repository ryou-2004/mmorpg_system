class Armor < Item
  enum :armor_category, {
    head: "head",       # 頭
    body: "body",       # 胴
    waist: "waist",     # 腰
    arm: "arm",         # 腕
    leg: "leg",         # 足
    shield: "shield"    # 盾
  }

  validates :armor_category, presence: true
  validates :equipment_slot, inclusion: { 
    in: %w[頭 胴 腰 腕 足 左手], 
    message: "は有効な防具スロットである必要があります" 
  }

  scope :light_armor, -> { where(armor_category: %w[head body waist]) }
  scope :medium_armor, -> { where(armor_category: %w[arm leg]) }
  scope :heavy_armor, -> { where(armor_category: %w[shield]) }

  def armor_category_name
    case armor_category
    when 'head' then '頭防具'
    when 'body' then '胴防具'
    when 'waist' then '腰防具'
    when 'arm' then '腕防具'
    when 'leg' then '足防具'
    when 'shield' then '盾'
    else armor_category
    end
  end

  def is_shield?
    armor_category == 'shield'
  end

  def covers_torso?
    %w[body waist].include?(armor_category)
  end

  def covers_limbs?
    %w[arm leg].include?(armor_category)
  end

  def covers_head?
    armor_category == 'head'
  end

  def defense_slot
    case armor_category
    when 'head' then '頭'
    when 'body' then '胴'
    when 'waist' then '腰'
    when 'arm' then '腕'
    when 'leg' then '足'
    when 'shield' then '左手'
    else equipment_slot
    end
  end
end