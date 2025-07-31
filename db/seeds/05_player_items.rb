# プレイヤーアイテムの作成

puts "プレイヤーアイテムを作成中..."

# 基本アイテムの取得
iron_sword = Item.find_by(name: "鉄の剣")
leather_armor = Item.find_by(name: "革の鎧")
health_potion = Item.find_by(name: "体力回復薬")
mana_potion = Item.find_by(name: "魔力回復薬")
magic_staff = Item.find_by(name: "魔法の杖")
dagger = Item.find_by(name: "短剣")
iron_ore = Item.find_by(name: "鉄鉱石")
power_ring = Item.find_by(name: "力の指輪")

# 各プレイヤーにアイテムを配布
Player.find_each do |player|
  # プレイヤーの最初の職業を取得
  first_job = player.job_classes.first

  case first_job&.name
  when "戦士"
    # 戦士には近接武器と防具
    PlayerItem.find_or_create_by(player: player, item: iron_sword) do |pi|
      pi.quantity = 1
      pi.equipped = true
      pi.durability = 100
      pi.max_durability = 100
    end

    PlayerItem.find_or_create_by(player: player, item: leather_armor) do |pi|
      pi.quantity = 1
      pi.equipped = true
      pi.durability = 95
      pi.max_durability = 100
    end

  when "魔法使い"
    # 魔法使いには杖
    PlayerItem.find_or_create_by(player: player, item: magic_staff) do |pi|
      pi.quantity = 1
      pi.equipped = true
      pi.durability = 100
      pi.max_durability = 100
    end

  when "盗賊"
    # 盗賊には短剣
    PlayerItem.find_or_create_by(player: player, item: dagger) do |pi|
      pi.quantity = 1
      pi.equipped = true
      pi.durability = 100
      pi.max_durability = 100
    end

  when "僧侶"
    # 僧侶には基本装備のみ（聖なる槌は高レベル用）
    PlayerItem.find_or_create_by(player: player, item: leather_armor) do |pi|
      pi.quantity = 1
      pi.equipped = true
      pi.durability = 90
      pi.max_durability = 100
    end
  end

  # 全プレイヤー共通アイテム

  # 体力回復薬（5-15個ランダム）
  PlayerItem.find_or_create_by(player: player, item: health_potion) do |pi|
    pi.quantity = rand(5..15)
    pi.equipped = false
  end

  # MP回復薬（3-8個ランダム）
  PlayerItem.find_or_create_by(player: player, item: mana_potion) do |pi|
    pi.quantity = rand(3..8)
    pi.equipped = false
  end

  # 鉄鉱石（素材アイテム）
  PlayerItem.find_or_create_by(player: player, item: iron_ore) do |pi|
    pi.quantity = rand(10..50)
    pi.equipped = false
  end

  # 一部のプレイヤーにレアアイテム（30%の確率）
  if rand < 0.3 && power_ring
    PlayerItem.find_or_create_by(player: player, item: power_ring) do |pi|
      pi.quantity = 1
      pi.equipped = false
      pi.durability = rand(80..100)
      pi.max_durability = 100
    end
  end
end

# 統計情報を表示
total_player_items = PlayerItem.count
equipped_items = PlayerItem.equipped.count
consumable_items = PlayerItem.joins(:item).where(items: { item_type: 'consumable' }).sum(:quantity)

puts "プレイヤーアイテムを作成しました:"
puts "- 総アイテム数: #{total_player_items}個"
puts "- 装備中アイテム: #{equipped_items}個"
puts "- 消耗品総数: #{consumable_items}個"

# プレイヤー別統計
Player.includes(:player_items, :items).each do |player|
  item_count = player.player_items.sum(:quantity)
  equipped_count = player.player_items.equipped.count
  puts "- #{player.name}: #{item_count}個のアイテム（装備中: #{equipped_count}個）"
end
