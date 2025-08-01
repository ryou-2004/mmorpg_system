# キャラクターアイテムの作成

puts "キャラクターアイテムを作成中..."

# 基本アイテムの取得
iron_sword = Item.find_by(name: "鉄の剣")
leather_armor = Item.find_by(name: "革の鎧")
health_potion = Item.find_by(name: "体力回復薬")
mana_potion = Item.find_by(name: "魔力回復薬")
magic_staff = Item.find_by(name: "魔法の杖")
dagger = Item.find_by(name: "短剣")
iron_ore = Item.find_by(name: "鉄鉱石")
power_ring = Item.find_by(name: "力の指輪")

# 各キャラクターにアイテムを配布
Character.find_each do |character|
  # キャラクターの最初の職業を取得
  first_job = character.job_classes.first

  case first_job&.name
  when "戦士"
    # 戦士には近接武器と防具
    CharacterItem.find_or_create_by(character: character, item: iron_sword) do |ci|
      ci.quantity = 1
      ci.equipped = true
      ci.durability = 100
      ci.max_durability = 100
    end

    CharacterItem.find_or_create_by(character: character, item: leather_armor) do |ci|
      ci.quantity = 1
      ci.equipped = true
      ci.durability = 95
      ci.max_durability = 100
    end

  when "魔法使い"
    # 魔法使いには杖
    CharacterItem.find_or_create_by(character: character, item: magic_staff) do |ci|
      ci.quantity = 1
      ci.equipped = true
      ci.durability = 100
      ci.max_durability = 100
    end

  when "盗賊"
    # 盗賊には短剣
    CharacterItem.find_or_create_by(character: character, item: dagger) do |ci|
      ci.quantity = 1
      ci.equipped = true
      ci.durability = 100
      ci.max_durability = 100
    end

  when "僧侶"
    # 僧侶には基本装備のみ（聖なる槌は高レベル用）
    CharacterItem.find_or_create_by(character: character, item: leather_armor) do |ci|
      ci.quantity = 1
      ci.equipped = true
      ci.durability = 90
      ci.max_durability = 100
    end
  end

  # 全キャラクター共通アイテム

  # 体力回復薬（5-15個ランダム）
  CharacterItem.find_or_create_by(character: character, item: health_potion) do |ci|
    ci.quantity = rand(5..15)
    ci.equipped = false
  end

  # MP回復薬（3-8個ランダム）
  CharacterItem.find_or_create_by(character: character, item: mana_potion) do |ci|
    ci.quantity = rand(3..8)
    ci.equipped = false
  end

  # 鉄鉱石（素材アイテム）
  CharacterItem.find_or_create_by(character: character, item: iron_ore) do |ci|
    ci.quantity = rand(10..50)
    ci.equipped = false
  end

  # 一部のキャラクターにレアアイテム（30%の確率）
  if rand < 0.3 && power_ring
    CharacterItem.find_or_create_by(character: character, item: power_ring) do |ci|
      ci.quantity = 1
      ci.equipped = false
      ci.durability = rand(80..100)
      ci.max_durability = 100
    end
  end
end

# 統計情報を表示
total_character_items = CharacterItem.count
equipped_items = CharacterItem.equipped.count
consumable_items = CharacterItem.joins(:item).where(items: { item_type: 'consumable' }).sum(:quantity)

puts "キャラクターアイテムを作成しました:"
puts "- 総アイテム数: #{total_character_items}個"
puts "- 装備中アイテム: #{equipped_items}個"
puts "- 消耗品総数: #{consumable_items}個"

# キャラクター別統計
Character.includes(:character_items, :items).each do |character|
  item_count = character.character_items.sum(:quantity)
  equipped_count = character.character_items.equipped.count
  puts "- #{character.name}: #{item_count}個のアイテム（装備中: #{equipped_count}個）"
end
