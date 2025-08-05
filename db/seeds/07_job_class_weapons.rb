# 職業別装備可能武器の定義
job_class_weapons_data = {
  '戦士' => [
    { weapon_category: 'one_hand_sword', unlock_level: 1 },
    { weapon_category: 'two_hand_sword', unlock_level: 5 },
    { weapon_category: 'spear', unlock_level: 10 },
    { weapon_category: 'axe', unlock_level: 15 },
    { weapon_category: 'hammer', unlock_level: 20 }
  ],
  '魔法使い' => [
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'dagger', unlock_level: 10 },
    { weapon_category: 'whip', unlock_level: 25 }
  ],
  '僧侶' => [
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'club', unlock_level: 5 },
    { weapon_category: 'spear', unlock_level: 15 }
  ],
  '盗賊' => [
    { weapon_category: 'dagger', unlock_level: 1 },
    { weapon_category: 'one_hand_sword', unlock_level: 10 },
    { weapon_category: 'whip', unlock_level: 20 },
    { weapon_category: 'boomerang', unlock_level: 30 }
  ],
  'パラディン' => [
    { weapon_category: 'one_hand_sword', unlock_level: 1 },
    { weapon_category: 'two_hand_sword', unlock_level: 1 },
    { weapon_category: 'spear', unlock_level: 1 },
    { weapon_category: 'axe', unlock_level: 10 },
    { weapon_category: 'hammer', unlock_level: 15 },
    { weapon_category: 'staff', unlock_level: 25 }
  ],
  '賢者' => [
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'dagger', unlock_level: 1 },
    { weapon_category: 'whip', unlock_level: 10 },
    { weapon_category: 'boomerang', unlock_level: 20 },
    { weapon_category: 'bow', unlock_level: 30 }
  ],
  'アサシン' => [
    { weapon_category: 'dagger', unlock_level: 1 },
    { weapon_category: 'one_hand_sword', unlock_level: 1 },
    { weapon_category: 'whip', unlock_level: 10 },
    { weapon_category: 'boomerang', unlock_level: 15 },
    { weapon_category: 'bow', unlock_level: 25 }
  ],
  '魔剣士' => [
    { weapon_category: 'one_hand_sword', unlock_level: 1 },
    { weapon_category: 'two_hand_sword', unlock_level: 1 },
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'spear', unlock_level: 10 },
    { weapon_category: 'whip', unlock_level: 20 }
  ],
  '召喚師' => [
    { weapon_category: 'staff', unlock_level: 1 },
    { weapon_category: 'whip', unlock_level: 10 },
    { weapon_category: 'boomerang', unlock_level: 20 }
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

# 二刀流可能職業の設定
dual_wield_jobs = ['盗賊', 'アサシン', '魔剣士']

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