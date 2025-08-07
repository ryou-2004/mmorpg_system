class Enemy < ApplicationRecord
  has_many :enemy_spawns, dependent: :destroy
  has_many :battle_participants, as: :character, dependent: :destroy
  has_many :battles, through: :battle_participants
  validates :name, presence: true, length: { maximum: 255 }
  validates :enemy_type, presence: true, inclusion: { in: %w[beast demon undead dragon humanoid plant elemental boss raid_boss] }
  validates :level, presence: true, numericality: { greater_than: 0, less_than_or_equal: 100 }
  validates :hp, :max_hp, :mp, :max_mp, :attack, :defense, :magic_attack, :magic_defense, :agility, :luck,
            presence: true, numericality: { greater_than: 0 }
  validates :experience_reward, :gold_reward, presence: true, numericality: { greater_than_or_equal: 0 }
  validates :battle_ai_type, inclusion: { in: %w[basic aggressive defensive magic_focused support random] }
  validates :size_category, inclusion: { in: %w[tiny small medium large huge colossal] }
  validates :spawn_rate, numericality: { in: 1..100 }

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(enemy_type: type) }
  scope :by_level_range, ->(min, max) { where(level: min..max) }
  scope :by_location, ->(location) { where(location: location) }
  scope :ordered_by_level, -> { order(:level, :name) }

  def enemy_type_name
    case enemy_type
    when "beast" then "獣"
    when "demon" then "悪魔"
    when "undead" then "アンデッド"
    when "dragon" then "ドラゴン"
    when "humanoid" then "人型"
    when "plant" then "植物"
    when "elemental" then "精霊"
    when "boss" then "ボス"
    when "raid_boss" then "レイドボス"
    else enemy_type
    end
  end

  def size_category_name
    case size_category
    when "tiny" then "極小"
    when "small" then "小"
    when "medium" then "中"
    when "large" then "大"
    when "huge" then "巨大"
    when "colossal" then "超巨大"
    else size_category
    end
  end

  def battle_ai_type_name
    case battle_ai_type
    when "basic" then "基本"
    when "aggressive" then "攻撃型"
    when "defensive" then "防御型"
    when "magic_focused" then "魔法特化"
    when "support" then "支援型"
    when "random" then "ランダム"
    else battle_ai_type
    end
  end

  def power_rating
    total_stats = attack + defense + magic_attack + magic_defense + agility + luck
    base_rating = (total_stats * level) / 10

    case enemy_type
    when "boss" then base_rating * 2
    when "raid_boss" then base_rating * 5
    else base_rating
    end
  end

  def difficulty_rank
    case power_rating
    when 0..100 then "E"
    when 101..200 then "D"
    when 201..350 then "C"
    when 351..500 then "B"
    when 501..750 then "A"
    when 751..1000 then "S"
    else "SS"
    end
  end

  def is_boss?
    enemy_type.include?("boss")
  end

  def is_elite?
    power_rating > (level * 20)
  end

  def resistances_summary
    return "なし" if resistances.blank?

    resistance_names = {
      "physical" => "物理",
      "fire" => "炎",
      "water" => "水",
      "earth" => "土",
      "air" => "風",
      "light" => "光",
      "dark" => "闇"
    }

    resistances.map do |type, value|
      name = resistance_names[type] || type
      "#{name}#{value}%"
    end.join(", ")
  end

  def skills_summary
    return "なし" if skills.blank?
    skills.map { |skill| skill["name"] }.join(", ")
  end

  def drop_items_summary
    return "なし" if drop_table.blank?

    drop_table.map do |drop|
      item_name = get_item_name(drop["type"], drop["item_id"])
      rate = drop["rate"]
      "#{item_name}(#{rate}%)"
    end.join(", ")
  end

  def can_spawn_at_level?(player_level)
    level_diff = (level - player_level).abs
    level_diff <= 10 # プレイヤーレベル±10の範囲でスポーン
  end

  def experience_for_player(player_level)
    base_exp = experience_reward
    level_diff = level - player_level

    if level_diff > 5
      (base_exp * 1.5).to_i # 高レベル敵からのボーナス
    elsif level_diff < -5
      (base_exp * 0.5).to_i # 低レベル敵からの減少
    else
      base_exp
    end
  end

  def gold_for_player(player_level)
    base_gold = gold_reward
    level_diff = level - player_level

    if level_diff > 5
      (base_gold * 1.2).to_i # 高レベル敵からのボーナス
    elsif level_diff < -5
      (base_gold * 0.8).to_i # 低レベル敵からの減少
    else
      base_gold
    end
  end

  def spawn_weight_for_location(player_level)
    return 0 unless can_spawn_at_level?(player_level)

    base_weight = spawn_rate
    level_diff = (level - player_level).abs

    # レベル差が大きいほど出現率を下げる
    weight_modifier = [ 100 - (level_diff * 5), 10 ].max
    (base_weight * weight_modifier / 100.0).to_i
  end

  private

  def get_item_name(type, item_id)
    case type
    when "Item"
      Item.find_by(id: item_id)&.name || "アイテム(ID: #{item_id})"
    else
      "#{type}(ID: #{item_id})"
    end
  rescue
    "#{type}(ID: #{item_id})"
  end
end
