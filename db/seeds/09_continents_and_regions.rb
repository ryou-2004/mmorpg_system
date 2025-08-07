# アストルテア大陸とその地域の設定

puts "大陸・地域システムを初期化中..."

# アストルテア大陸を作成
continent = Continent.find_or_create_by(name: "astoltea") do |c|
  c.display_name = "アストルテア大陸"
  c.description = "冒険の始まりの地。豊かな自然と古代の遺跡が点在する大陸。"
  c.world_position_x = 0
  c.world_position_y = 0
  c.grid_width = 8
  c.grid_height = 8
  c.active = true
end

puts "大陸作成完了: #{continent.display_name}"

# 8×8の地域データ定義
regions_data = [
  # A列 - 西の辺境
  { grid: 'A1', name: 'westland_meadow', display_name: '西の草原', type: 'field', terrain: 'grassland', level: [1, 3], climate: 'temperate' },
  { grid: 'A2', name: 'whispering_woods', display_name: 'ささやきの森', type: 'field', terrain: 'forest', level: [2, 5], climate: 'temperate' },
  { grid: 'A3', name: 'misty_swamp', display_name: '霧の沼地', type: 'field', terrain: 'swamp', level: [4, 8], climate: 'humid' },
  { grid: 'A4', name: 'scorching_desert', display_name: '灼熱砂漠', type: 'field', terrain: 'desert', level: [10, 15], climate: 'hot' },
  { grid: 'A5', name: 'endless_sands', display_name: '果てなき砂丘', type: 'field', terrain: 'desert', level: [12, 18], climate: 'hot' },
  { grid: 'A6', name: 'cursed_wasteland', display_name: '呪われた荒地', type: 'field', terrain: 'desert', level: [18, 25], climate: 'dry' },
  { grid: 'A7', name: 'toxic_marsh', display_name: '毒の湿原', type: 'field', terrain: 'swamp', level: [22, 30], climate: 'humid' },
  { grid: 'A8', name: 'abyss_entrance', display_name: '深淵の入口', type: 'special', terrain: 'ruins', level: [35, 50], climate: 'cold' },

  # B列 - 森林と遺跡
  { grid: 'B1', name: 'emerald_forest', display_name: '翠緑の森', type: 'field', terrain: 'forest', level: [2, 4], climate: 'temperate' },
  { grid: 'B2', name: 'ancient_ruins', display_name: '古代遺跡', type: 'dungeon', terrain: 'ruins', level: [5, 10], climate: 'temperate' },
  { grid: 'B3', name: 'elderwood', display_name: '古老の森', type: 'field', terrain: 'forest', level: [6, 12], climate: 'temperate' },
  { grid: 'B4', name: 'mirage_oasis', display_name: '蜃気楼のオアシス', type: 'field', terrain: 'desert', level: [8, 14], climate: 'hot' },
  { grid: 'B5', name: 'shifting_dunes', display_name: '流砂の砂漠', type: 'field', terrain: 'desert', level: [14, 20], climate: 'hot' },
  { grid: 'B6', name: 'desolate_badlands', display_name: '荒涼の悪地', type: 'field', terrain: 'desert', level: [20, 28], climate: 'dry' },
  { grid: 'B7', name: 'forgotten_desert', display_name: '忘れられた砂漠', type: 'field', terrain: 'desert', level: [25, 35], climate: 'hot' },
  { grid: 'B8', name: 'infernal_gates', display_name: '地獄の門', type: 'special', terrain: 'volcano', level: [40, 60], climate: 'hot' },

  # C列 - 山岳地帯
  { grid: 'C1', name: 'rolling_hills', display_name: 'なだらかな丘陵', type: 'field', terrain: 'mountain', level: [3, 6], climate: 'temperate' },
  { grid: 'C2', name: 'stone_peaks', display_name: '石の峰', type: 'field', terrain: 'mountain', level: [6, 12], climate: 'cold' },
  { grid: 'C3', name: 'mountain_range', display_name: '連峰', type: 'field', terrain: 'mountain', level: [10, 18], climate: 'cold' },
  { grid: 'C4', name: 'rocky_cliffs', display_name: '岩の断崖', type: 'field', terrain: 'mountain', level: [12, 20], climate: 'dry' },
  { grid: 'C5', name: 'fire_mountain', display_name: '炎の山', type: 'dungeon', terrain: 'volcano', level: [15, 25], climate: 'hot' },
  { grid: 'C6', name: 'lava_fields', display_name: '溶岩台地', type: 'field', terrain: 'volcano', level: [20, 30], climate: 'hot' },
  { grid: 'C7', name: 'volcanic_crater', display_name: '火山の火口', type: 'dungeon', terrain: 'volcano', level: [25, 38], climate: 'hot' },
  { grid: 'C8', name: 'demon_realm', display_name: '魔界', type: 'special', terrain: 'volcano', level: [45, 70], climate: 'hot' },

  # D列 - 洞窟と神殿
  { grid: 'D1', name: 'crystal_cave', display_name: '水晶の洞窟', type: 'dungeon', terrain: 'cave', level: [4, 8], climate: 'temperate' },
  { grid: 'D2', name: 'shadow_grove', display_name: '影の森', type: 'field', terrain: 'forest', level: [7, 13], climate: 'temperate' },
  { grid: 'D3', name: 'limestone_cavern', display_name: '石灰岩の洞窟', type: 'dungeon', terrain: 'cave', level: [9, 16], climate: 'temperate' },
  { grid: 'D4', name: 'sun_temple', display_name: '太陽神殿', type: 'dungeon', terrain: 'ruins', level: [13, 22], climate: 'hot' },
  { grid: 'D5', name: 'underground_lake', display_name: '地底湖', type: 'dungeon', terrain: 'cave', level: [16, 26], climate: 'cold' },
  { grid: 'D6', name: 'depths_of_earth', display_name: '大地の深奥', type: 'dungeon', terrain: 'cave', level: [22, 32], climate: 'cold' },
  { grid: 'D7', name: 'void_temple', display_name: '虚無の神殿', type: 'special', terrain: 'ruins', level: [28, 42], climate: 'cold' },
  { grid: 'D8', name: 'netherworld', display_name: '奈落', type: 'special', terrain: 'cave', level: [50, 80], climate: 'cold' },

  # E列 - 村と街道
  { grid: 'E1', name: 'starter_village', display_name: '始まりの村', type: 'town', terrain: 'grassland', level: [1, 1], climate: 'temperate' },
  { grid: 'E2', name: 'merchant_city', display_name: '商業都市', type: 'town', terrain: 'grassland', level: [5, 5], climate: 'temperate' },
  { grid: 'E3', name: 'farming_plains', display_name: '農耕平野', type: 'field', terrain: 'grassland', level: [3, 8], climate: 'temperate' },
  { grid: 'E4', name: 'trade_route', display_name: '街道', type: 'field', terrain: 'grassland', level: [8, 15], climate: 'temperate' },
  { grid: 'E5', name: 'woodland_village', display_name: '森の村', type: 'town', terrain: 'forest', level: [10, 10], climate: 'temperate' },
  { grid: 'E6', name: 'ancient_castle', display_name: '古城', type: 'dungeon', terrain: 'ruins', level: [18, 28], climate: 'temperate' },
  { grid: 'E7', name: 'ghost_town', display_name: '廃墟の街', type: 'dungeon', terrain: 'ruins', level: [24, 36], climate: 'dry' },
  { grid: 'E8', name: 'battlefield', display_name: '古戦場', type: 'special', terrain: 'grassland', level: [40, 55], climate: 'temperate' },

  # F列 - 水辺と森
  { grid: 'F1', name: 'peaceful_woods', display_name: '平和な森', type: 'field', terrain: 'forest', level: [1, 4], climate: 'temperate' },
  { grid: 'F2', name: 'farming_fields', display_name: '農地', type: 'field', terrain: 'grassland', level: [2, 6], climate: 'temperate' },
  { grid: 'F3', name: 'harvest_valley', display_name: '収穫の谷', type: 'field', terrain: 'grassland', level: [4, 9], climate: 'temperate' },
  { grid: 'F4', name: 'whispering_forest', display_name: 'ささやきの森', type: 'field', terrain: 'forest', level: [6, 14], climate: 'temperate' },
  { grid: 'F5', name: 'crystal_lake', display_name: '水晶湖', type: 'field', terrain: 'lake', level: [10, 18], climate: 'temperate' },
  { grid: 'F6', name: 'mystic_lake', display_name: '神秘の湖', type: 'field', terrain: 'lake', level: [15, 25], climate: 'temperate' },
  { grid: 'F7', name: 'dark_forest', display_name: '暗黒の森', type: 'field', terrain: 'forest', level: [20, 32], climate: 'cold' },
  { grid: 'F8', name: 'cursed_lake', display_name: '呪いの湖', type: 'special', terrain: 'lake', level: [35, 50], climate: 'cold' },

  # G列 - 川と橋
  { grid: 'G1', name: 'clear_stream', display_name: '清流', type: 'field', terrain: 'river', level: [2, 5], climate: 'temperate' },
  { grid: 'G2', name: 'stone_bridge', display_name: '石橋', type: 'field', terrain: 'bridge', level: [3, 7], climate: 'temperate' },
  { grid: 'G3', name: 'wooden_bridge', display_name: '木橋', type: 'field', terrain: 'bridge', level: [5, 11], climate: 'temperate' },
  { grid: 'G4', name: 'great_river', display_name: '大河', type: 'field', terrain: 'river', level: [8, 16], climate: 'temperate' },
  { grid: 'G5', name: 'forest_stream', display_name: '森の小川', type: 'field', terrain: 'river', level: [12, 20], climate: 'temperate' },
  { grid: 'G6', name: 'mountain_stream', display_name: '山の渓流', type: 'field', terrain: 'river', level: [16, 26], climate: 'cold' },
  { grid: 'G7', name: 'shadow_river', display_name: '影の川', type: 'field', terrain: 'river', level: [22, 34], climate: 'cold' },
  { grid: 'G8', name: 'river_of_souls', display_name: '魂の川', type: 'special', terrain: 'river', level: [38, 55], climate: 'cold' },

  # H列 - 海岸と要塞
  { grid: 'H1', name: 'sunny_coast', display_name: '陽光海岸', type: 'field', terrain: 'ocean', level: [3, 7], climate: 'temperate' },
  { grid: 'H2', name: 'fishing_port', display_name: '漁港', type: 'town', terrain: 'ocean', level: [6, 6], climate: 'temperate' },
  { grid: 'H3', name: 'coral_island', display_name: '珊瑚の島', type: 'field', terrain: 'ocean', level: [8, 15], climate: 'temperate' },
  { grid: 'H4', name: 'lighthouse', display_name: '灯台', type: 'field', terrain: 'ocean', level: [12, 20], climate: 'temperate' },
  { grid: 'H5', name: 'royal_castle', display_name: '王の城', type: 'town', terrain: 'grassland', level: [15, 15], climate: 'temperate' },
  { grid: 'H6', name: 'coastal_fortress', display_name: '海岸要塞', type: 'dungeon', terrain: 'ocean', level: [18, 30], climate: 'temperate' },
  { grid: 'H7', name: 'demon_castle', display_name: '魔王城', type: 'special', terrain: 'ruins', level: [30, 45], climate: 'cold' },
  { grid: 'H8', name: 'overlord_citadel', display_name: '覇王の城塞', type: 'special', terrain: 'ruins', level: [50, 99], climate: 'cold' }
]

puts "#{regions_data.size}の地域を作成中..."

regions_data.each do |data|
  grid_x, grid_y = data[:grid][0], data[:grid][1..-1].to_i
  
  region = Region.find_or_create_by(
    continent: continent,
    grid_x: grid_x,
    grid_y: grid_y
  ) do |r|
    r.name = data[:name]
    r.display_name = data[:display_name]
    r.region_type = data[:type]
    r.terrain_type = data[:terrain]
    r.level_range_min = data[:level][0]
    r.level_range_max = data[:level][1]
    r.climate = data[:climate]
    r.accessibility = 'always'
    r.active = true
    
    # 地域タイプ別の説明を自動生成
    case data[:type]
    when 'town'
      r.description = "安全な街や村。回復・補給・クエスト受注が可能。"
    when 'dungeon'
      r.description = "危険なダンジョン。強力な敵と貴重な宝が眠る。"
    when 'field'
      r.description = "#{data[:display_name]}の#{r.terrain_type_name}地帯。様々な魔物が生息している。"
    when 'special'
      r.description = "特殊なエリア。強大な力を持つ存在が潜んでいる。"
    end
  end
  
  print "."
end

puts "\n地域作成完了: #{regions_data.size}地域"

# 統計情報表示
puts "\n=== アストルテア大陸 統計 ==="
puts "大陸名: #{continent.display_name}"
puts "グリッドサイズ: #{continent.grid_width}×#{continent.grid_height}"
puts "総地域数: #{continent.regions.count}"

region_types = continent.regions.group(:region_type).count
puts "\n地域タイプ別統計:"
region_types.each do |type, count|
  type_name = case type
  when 'field' then 'フィールド'
  when 'dungeon' then 'ダンジョン'
  when 'town' then '街・村'
  when 'special' then '特殊エリア'
  end
  puts "  #{type_name}: #{count}箇所"
end

terrain_types = continent.regions.group(:terrain_type).count
puts "\n地形タイプ別統計:"
terrain_types.each do |terrain, count|
  puts "  #{terrain}: #{count}箇所"
end

level_ranges = continent.regions.group_by { |r| 
  case r.level_range_max
  when 1..10 then '初心者エリア(Lv.1-10)'
  when 11..25 then '中級エリア(Lv.11-25)'  
  when 26..40 then '上級エリア(Lv.26-40)'
  else '最高級エリア(Lv.41+)'
  end
}
puts "\nレベル帯別統計:"
level_ranges.each do |range, regions|
  puts "  #{range}: #{regions.size}箇所"
end

puts "\nアストルテア大陸の準備が完了しました！"