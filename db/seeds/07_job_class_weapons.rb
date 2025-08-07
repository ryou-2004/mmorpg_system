# ドラクエ10全職業の装備可能武器定義
job_class_weapons_data = {
  # 基本職業
  '戦士' => [
    { weapon_category: 'one_hand_sword', unlock_level: 1 },
    { weapon_category: 'two_hand_sword', unlock_level: 5 },
    { weapon_category: 'axe', unlock_level: 10 }
  ],
  '魔法使い' => [
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'dagger', unlock_level: 10 },
    { weapon_category: 'whip', unlock_level: 15 }
  ],
  '僧侶' => [
    { weapon_category: 'spear', unlock_level: 1 },
    { weapon_category: 'club', unlock_level: 5 },
    { weapon_category: 'stick', unlock_level: 10 }
  ],
  '武闘家' => [
    { weapon_category: 'club', unlock_level: 1 },
    { weapon_category: 'fan', unlock_level: 5 },
    { weapon_category: 'claw', unlock_level: 10 },
    { weapon_category: 'martial_arts', unlock_level: 1 }
  ],
  '盗賊' => [
    { weapon_category: 'dagger', unlock_level: 1 },
    { weapon_category: 'claw', unlock_level: 5 },
    { weapon_category: 'whip', unlock_level: 10 },
    { weapon_category: 'martial_arts', unlock_level: 15 }
  ],
  '旅芸人' => [
    { weapon_category: 'fan', unlock_level: 1 },
    { weapon_category: 'dagger', unlock_level: 5 },
    { weapon_category: 'club', unlock_level: 10 }
  ],

  # 上級職業
  'バトルマスター' => [
    { weapon_category: 'one_hand_sword', unlock_level: 1 },
    { weapon_category: 'two_hand_sword', unlock_level: 1 },
    { weapon_category: 'hammer', unlock_level: 5 },
    { weapon_category: 'martial_arts', unlock_level: 10 }
  ],
  'パラディン' => [
    { weapon_category: 'hammer', unlock_level: 1 },
    { weapon_category: 'spear', unlock_level: 1 },
    { weapon_category: 'stick', unlock_level: 5 }
  ],
  '魔法戦士' => [
    { weapon_category: 'one_hand_sword', unlock_level: 1 },
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'bow', unlock_level: 10 }
  ],
  'まもの使い' => [
    { weapon_category: 'claw', unlock_level: 1 },
    { weapon_category: 'whip', unlock_level: 5 },
    { weapon_category: 'axe', unlock_level: 10 },
    { weapon_category: 'two_hand_sword', unlock_level: 15 }
  ],
  'どうぐ使い' => [
    { weapon_category: 'bow', unlock_level: 1 },
    { weapon_category: 'hammer', unlock_level: 5 },
    { weapon_category: 'boomerang', unlock_level: 10 },
    { weapon_category: 'spear', unlock_level: 15 }
  ],
  'レンジャー' => [
    { weapon_category: 'bow', unlock_level: 1 },
    { weapon_category: 'boomerang', unlock_level: 5 },
    { weapon_category: 'axe', unlock_level: 10 },
    { weapon_category: 'martial_arts', unlock_level: 15 }
  ],
  'スーパースター' => [
    { weapon_category: 'whip', unlock_level: 1 },
    { weapon_category: 'fan', unlock_level: 5 },
    { weapon_category: 'stick', unlock_level: 10 },
    { weapon_category: 'martial_arts', unlock_level: 15 }
  ],
  '賢者' => [
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'bow', unlock_level: 5 },
    { weapon_category: 'boomerang', unlock_level: 10 }
  ],
  '踊り子' => [
    { weapon_category: 'dagger', unlock_level: 1 },
    { weapon_category: 'stick', unlock_level: 5 },
    { weapon_category: 'fan', unlock_level: 10 }
  ],
  '占い師' => [
    { weapon_category: 'one_hand_sword', unlock_level: 1 },
    { weapon_category: 'club', unlock_level: 5 },
    { weapon_category: 'bow', unlock_level: 10 },
    { weapon_category: 'whip', unlock_level: 15 }
  ],

  # 特殊職業
  '海賊' => [
    { weapon_category: 'axe', unlock_level: 1 },
    { weapon_category: 'hammer', unlock_level: 5 },
    { weapon_category: 'one_hand_sword', unlock_level: 10 }
  ],
  'デスマスター' => [
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'claw', unlock_level: 5 },
    { weapon_category: 'whip', unlock_level: 10 }
  ],
  'ガーディアン' => [
    { weapon_category: 'one_hand_sword', unlock_level: 1 },
    { weapon_category: 'two_hand_sword', unlock_level: 1 },
    { weapon_category: 'hammer', unlock_level: 5 },
    { weapon_category: 'spear', unlock_level: 10 }
  ],
  'ドラゴンテイマー' => [
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'spear', unlock_level: 5 },
    { weapon_category: 'whip', unlock_level: 10 }
  ],
  '天地雷鳴士' => [
    { weapon_category: 'fan', unlock_level: 1 },
    { weapon_category: 'club', unlock_level: 5 },
    { weapon_category: 'bow', unlock_level: 10 }
  ]
}

# 職業別装備可能武器の作成
job_class_weapons_data.each do |job_name, weapons|
  job_class = JobClass.find_by(name: job_name)
  next unless job_class

  weapons.each do |weapon_data|
    JobClassWeapon.find_or_create_by!(
      job_class: job_class,
      weapon_category: weapon_data[:weapon_category]
    ) do |jcw|
      jcw.unlock_level = weapon_data[:unlock_level]
      jcw.active = true
    end
  end
end

# 二刀流可能職業の設定（ドラクエ10準拠）
dual_wield_jobs = [ '武闘家', '盗賊', '踊り子' ]

dual_wield_jobs.each do |job_name|
  job = JobClass.find_by(name: job_name)
  if job && !job.can_equip_left_hand
    job.update!(can_equip_left_hand: true)
    puts "#{job_name}に二刀流能力を追加しました"
  end
end

puts "職業別装備可能武器を作成しました"
JobClass.find_each do |job|
  weapons_count = job.job_class_weapons.count
  weapon_names = job.job_class_weapons.order(:unlock_level).pluck(:weapon_category).map { |cat|
    I18n.t("weapons.categories.#{cat}", default: cat)
  }.join(', ')
  puts "#{job.name}: #{weapons_count}種類の武器 (#{weapon_names})"
end
