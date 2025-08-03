class Armor < Item
  enum :armor_category, {
    head: "head",       # 頭
    body: "body",       # 胴
    waist: "waist",     # 腰
    arm: "arm",         # 腕
    leg: "leg",         # 足
    shield: "shield"    # 盾
  }, validate: true

  validates :armor_category, presence: true
  validates :equipment_slot, inclusion: { 
    in: %w[頭 胴 腰 腕 足 左手], 
    message: "は有効な防具スロットである必要があります" 
  }

  scope :shields, -> { where(armor_category: 'shield') }
  scope :head_armor, -> { where(armor_category: 'head') }
  scope :body_armor, -> { where(armor_category: 'body') }
  scope :waist_armor, -> { where(armor_category: 'waist') }
  scope :arm_armor, -> { where(armor_category: 'arm') }
  scope :leg_armor, -> { where(armor_category: 'leg') }

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