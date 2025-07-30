# アイテムの作成

puts "アイテムを作成中..."

# === 武器 ===
weapons = [
  {
    name: "鉄の剣",
    description: "鍛冶屋で作られた基本的な剣。攻撃力+10",
    item_type: "weapon",
    rarity: "common",
    max_stack: 1,
    buy_price: 500,
    sell_price: 125,
    level_requirement: 1,
    job_requirement: ["戦士", "パラディン", "魔剣士"],
    effects: [
      { type: "stat_boost", stat: "attack", value: 10 }
    ],
    sale_type: "both",
    icon_path: "weapons/iron_sword.png"
  },
  {
    name: "魔法の杖",
    description: "魔力を込められた杖。魔法攻撃力+12",
    item_type: "weapon",
    rarity: "uncommon",
    max_stack: 1,
    buy_price: 800,
    sell_price: 200,
    level_requirement: 5,
    job_requirement: ["魔法使い", "賢者", "召喚師"],
    effects: [
      { type: "stat_boost", stat: "magic_attack", value: 12 }
    ],
    sale_type: "both",
    icon_path: "weapons/magic_staff.png"
  },
  {
    name: "短剣",
    description: "軽量で扱いやすい短剣。攻撃力+8、素早さ+3",
    item_type: "weapon",
    rarity: "common",
    max_stack: 1,
    buy_price: 400,
    sell_price: 100,
    level_requirement: 1,
    job_requirement: ["盗賊", "アサシン"],
    effects: [
      { type: "stat_boost", stat: "attack", value: 8 },
      { type: "stat_boost", stat: "agility", value: 3 }
    ],
    sale_type: "both",
    icon_path: "weapons/dagger.png"
  },
  {
    name: "聖なる槌",
    description: "神聖な力を宿した槌。攻撃力+15、MP回復効果",
    item_type: "weapon",
    rarity: "rare",
    max_stack: 1,
    buy_price: 2000,
    sell_price: 500,
    level_requirement: 10,
    job_requirement: ["僧侶", "パラディン"],
    effects: [
      { type: "stat_boost", stat: "attack", value: 15 },
      { type: "mp_regeneration", value: 2 }
    ],
    sale_type: "shop",
    icon_path: "weapons/holy_hammer.png"
  },
  {
    name: "ドラゴンスレイヤー",
    description: "伝説のドラゴンを倒した剣。攻撃力+30",
    item_type: "weapon",
    rarity: "legendary",
    max_stack: 1,
    buy_price: 50000,
    sell_price: 12500,
    level_requirement: 25,
    job_requirement: ["戦士", "パラディン", "魔剣士"],
    effects: [
      { type: "stat_boost", stat: "attack", value: 30 },
      { type: "damage_bonus", target: "dragon", multiplier: 2.0 }
    ],
    sale_type: "bazaar",
    icon_path: "weapons/dragonslayer.png"
  }
]

# === 防具 ===
armors = [
  {
    name: "革の鎧",
    description: "柔らかい革で作られた軽装鎧。防御力+5",
    item_type: "armor",
    rarity: "common",
    max_stack: 1,
    buy_price: 300,
    sell_price: 75,
    level_requirement: 1,
    job_requirement: [],
    effects: [
      { type: "stat_boost", stat: "defense", value: 5 }
    ],
    sale_type: "both",
    icon_path: "armors/leather_armor.png"
  },
  {
    name: "鋼の鎧",
    description: "頑丈な鋼で作られた重装鎧。防御力+15、素早さ-2",
    item_type: "armor",
    rarity: "uncommon",
    max_stack: 1,
    buy_price: 1200,
    sell_price: 300,
    level_requirement: 8,
    job_requirement: ["戦士", "パラディン"],
    effects: [
      { type: "stat_boost", stat: "defense", value: 15 },
      { type: "stat_boost", stat: "agility", value: -2 }
    ],
    sale_type: "both",
    icon_path: "armors/steel_armor.png"
  },
  {
    name: "賢者のローブ",
    description: "魔法使いが好む軽やかなローブ。魔法防御力+10、MP+20",
    item_type: "armor",
    rarity: "rare",
    max_stack: 1,
    buy_price: 1800,
    sell_price: 450,
    level_requirement: 12,
    job_requirement: ["魔法使い", "賢者", "召喚師"],
    effects: [
      { type: "stat_boost", stat: "magic_defense", value: 10 },
      { type: "stat_boost", stat: "max_mp", value: 20 }
    ],
    sale_type: "shop",
    icon_path: "armors/sage_robe.png"
  }
]

# === アクセサリー ===
accessories = [
  {
    name: "力の指輪",
    description: "装着者の力を高める指輪。攻撃力+5",
    item_type: "accessory",
    rarity: "uncommon",
    max_stack: 1,
    buy_price: 1000,
    sell_price: 250,
    level_requirement: 5,
    job_requirement: [],
    effects: [
      { type: "stat_boost", stat: "attack", value: 5 }
    ],
    sale_type: "both",
    icon_path: "accessories/power_ring.png"
  },
  {
    name: "護りのアミュレット",
    description: "魔法の護りが込められたお守り。全防御力+3",
    item_type: "accessory",
    rarity: "rare",
    max_stack: 1,
    buy_price: 2500,
    sell_price: 625,
    level_requirement: 10,
    job_requirement: [],
    effects: [
      { type: "stat_boost", stat: "defense", value: 3 },
      { type: "stat_boost", stat: "magic_defense", value: 3 }
    ],
    sale_type: "shop",
    icon_path: "accessories/protection_amulet.png"
  }
]

# === 消耗品 ===
consumables = [
  {
    name: "体力回復薬",
    description: "飲むとHPが50回復する。",
    item_type: "consumable",
    rarity: "common",
    max_stack: 99,
    buy_price: 50,
    sell_price: 12,
    level_requirement: 1,
    job_requirement: [],
    effects: [
      { type: "heal", value: 50 }
    ],
    sale_type: "both",
    icon_path: "consumables/health_potion.png"
  },
  {
    name: "魔力回復薬",
    description: "飲むとMPが30回復する。",
    item_type: "consumable",
    rarity: "common",
    max_stack: 99,
    buy_price: 80,
    sell_price: 20,
    level_requirement: 1,
    job_requirement: [],
    effects: [
      { type: "mp_heal", value: 30 }
    ],
    sale_type: "both",
    icon_path: "consumables/mana_potion.png"
  },
  {
    name: "上級体力回復薬",
    description: "飲むとHPが150回復する。",
    item_type: "consumable",
    rarity: "uncommon",
    max_stack: 50,
    buy_price: 200,
    sell_price: 50,
    level_requirement: 10,
    job_requirement: [],
    effects: [
      { type: "heal", value: 150 }
    ],
    sale_type: "both",
    icon_path: "consumables/greater_health_potion.png"
  },
  {
    name: "経験値ブースター",
    description: "使用すると30分間経験値が1.5倍になる。",
    item_type: "consumable",
    rarity: "rare",
    max_stack: 10,
    buy_price: 1000,
    sell_price: 250,
    level_requirement: 5,
    job_requirement: [],
    effects: [
      { type: "exp_boost", multiplier: 1.5, duration: 1800 }
    ],
    sale_type: "shop",
    icon_path: "consumables/exp_booster.png"
  }
]

# === 素材 ===
materials = [
  {
    name: "鉄鉱石",
    description: "武器や防具の材料になる基本的な鉱石。",
    item_type: "material",
    rarity: "common",
    max_stack: 999,
    buy_price: 10,
    sell_price: 3,
    level_requirement: 1,
    job_requirement: [],
    effects: [],
    sale_type: "both",
    icon_path: "materials/iron_ore.png"
  },
  {
    name: "魔法の水晶",
    description: "魔法のエネルギーが込められた水晶。",
    item_type: "material",
    rarity: "uncommon",
    max_stack: 99,
    buy_price: 100,
    sell_price: 25,
    level_requirement: 1,
    job_requirement: [],
    effects: [],
    sale_type: "both",
    icon_path: "materials/magic_crystal.png"
  },
  {
    name: "ドラゴンの鱗",
    description: "ドラゴンから取れる貴重な鱗。最高級装備の材料。",
    item_type: "material",
    rarity: "legendary",
    max_stack: 10,
    buy_price: 5000,
    sell_price: 1250,
    level_requirement: 20,
    job_requirement: [],
    effects: [],
    sale_type: "bazaar",
    icon_path: "materials/dragon_scale.png"
  }
]

# === クエストアイテム ===
quest_items = [
  {
    name: "古い手紙",
    description: "誰かからの重要な手紙のようだ。",
    item_type: "quest",
    rarity: "common",
    max_stack: 1,
    buy_price: 0,
    sell_price: 0,
    level_requirement: 1,
    job_requirement: [],
    effects: [],
    sale_type: "unsellable",
    icon_path: "quest/old_letter.png"
  },
  {
    name: "王の印章",
    description: "王室の正式な印章。非常に重要なアイテム。",
    item_type: "quest",
    rarity: "epic",
    max_stack: 1,
    buy_price: 0,
    sell_price: 0,
    level_requirement: 15,
    job_requirement: [],
    effects: [],
    sale_type: "unsellable",
    icon_path: "quest/royal_seal.png"
  }
]

# 全アイテムを作成
all_items = weapons + armors + accessories + consumables + materials + quest_items

all_items.each do |item_data|
  Item.find_or_create_by(name: item_data[:name]) do |item|
    item.description = item_data[:description]
    item.item_type = item_data[:item_type]
    item.rarity = item_data[:rarity]
    item.max_stack = item_data[:max_stack]
    item.buy_price = item_data[:buy_price]
    item.sell_price = item_data[:sell_price]
    item.level_requirement = item_data[:level_requirement]
    item.job_requirement = item_data[:job_requirement]
    item.effects = item_data[:effects]
    item.sale_type = item_data[:sale_type]
    item.icon_path = item_data[:icon_path]
    item.active = true
  end
end

puts "アイテムを作成しました:"
puts "- 武器: #{weapons.length}種類"
puts "- 防具: #{armors.length}種類"
puts "- アクセサリー: #{accessories.length}種類"
puts "- 消耗品: #{consumables.length}種類"
puts "- 素材: #{materials.length}種類"
puts "- クエストアイテム: #{quest_items.length}種類"
puts "合計: #{all_items.length}種類のアイテム"