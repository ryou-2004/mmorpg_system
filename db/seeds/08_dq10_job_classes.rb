# ドラクエ10全職業データ
dq10_job_classes = [
  # 基本職業
  {
    name: '武闘家',
    description: '素手や爪での格闘戦を得意とし、高い俊敏性を持つ。',
    job_type: 'basic',
    max_level: 50,
    exp_multiplier: 0.9,
    hp_multiplier: 1.1,
    mp_multiplier: 0.9,
    attack_multiplier: 1.1,
    defense_multiplier: 0.9,
    magic_attack_multiplier: 0.8,
    magic_defense_multiplier: 0.9,
    agility_multiplier: 1.3,
    luck_multiplier: 1.2,
    can_equip_left_hand: true  # 二刀流可能
  },
  {
    name: '旅芸人',
    description: '様々な特技で仲間をサポートする芸達者な職業。',
    job_type: 'basic',
    max_level: 50,
    exp_multiplier: 1.0,
    hp_multiplier: 1.0,
    mp_multiplier: 1.1,
    attack_multiplier: 0.9,
    defense_multiplier: 1.0,
    magic_attack_multiplier: 1.0,
    magic_defense_multiplier: 1.1,
    agility_multiplier: 1.1,
    luck_multiplier: 1.2
  },
  
  # 上級職業
  {
    name: 'バトルマスター',
    description: '戦士の上位職。強力な武器技と高い攻撃力を持つ。',
    job_type: 'advanced',
    max_level: 70,
    exp_multiplier: 1.4,
    hp_multiplier: 1.2,
    mp_multiplier: 0.9,
    attack_multiplier: 1.3,
    defense_multiplier: 1.1,
    magic_attack_multiplier: 0.8,
    magic_defense_multiplier: 0.9,
    agility_multiplier: 1.0,
    luck_multiplier: 1.0
  },
  {
    name: 'まもの使い',
    description: '魔物を仲間にし、共に戦う特殊な職業。',
    job_type: 'advanced',
    max_level: 65,
    exp_multiplier: 1.3,
    hp_multiplier: 1.1,
    mp_multiplier: 1.0,
    attack_multiplier: 1.1,
    defense_multiplier: 1.0,
    magic_attack_multiplier: 0.9,
    magic_defense_multiplier: 1.0,
    agility_multiplier: 1.1,
    luck_multiplier: 1.1
  },
  {
    name: 'どうぐ使い',
    description: '道具やアイテムを巧みに扱い、多彩な戦術を展開。',
    job_type: 'advanced',
    max_level: 60,
    exp_multiplier: 1.2,
    hp_multiplier: 1.0,
    mp_multiplier: 1.1,
    attack_multiplier: 1.0,
    defense_multiplier: 1.0,
    magic_attack_multiplier: 1.0,
    magic_defense_multiplier: 1.0,
    agility_multiplier: 1.2,
    luck_multiplier: 1.3
  },
  {
    name: 'レンジャー',
    description: '弓術と野外戦闘に長けた遊撃の専門家。',
    job_type: 'advanced',
    max_level: 65,
    exp_multiplier: 1.3,
    hp_multiplier: 1.0,
    mp_multiplier: 1.0,
    attack_multiplier: 1.1,
    defense_multiplier: 0.9,
    magic_attack_multiplier: 0.9,
    magic_defense_multiplier: 0.9,
    agility_multiplier: 1.3,
    luck_multiplier: 1.2
  },
  {
    name: '魔法戦士',
    description: '剣術と魔法を巧みに組み合わせる万能職業。',
    job_type: 'advanced',
    max_level: 70,
    exp_multiplier: 1.6,
    hp_multiplier: 1.1,
    mp_multiplier: 1.2,
    attack_multiplier: 1.1,
    defense_multiplier: 1.0,
    magic_attack_multiplier: 1.2,
    magic_defense_multiplier: 1.1,
    agility_multiplier: 1.0,
    luck_multiplier: 1.0
  },
  {
    name: 'スーパースター',
    description: '華やかな技で仲間を魅了し、戦闘を有利に導く。',
    job_type: 'advanced',
    max_level: 65,
    exp_multiplier: 1.4,
    hp_multiplier: 1.0,
    mp_multiplier: 1.1,
    attack_multiplier: 0.9,
    defense_multiplier: 0.9,
    magic_attack_multiplier: 1.1,
    magic_defense_multiplier: 1.1,
    agility_multiplier: 1.2,
    luck_multiplier: 1.3
  },
  {
    name: '踊り子',
    description: '優雅な踊りで仲間を強化し、敵を翻弄する。',
    job_type: 'advanced',
    max_level: 60,
    exp_multiplier: 1.3,
    hp_multiplier: 0.9,
    mp_multiplier: 1.1,
    attack_multiplier: 0.9,
    defense_multiplier: 0.8,
    magic_attack_multiplier: 1.0,
    magic_defense_multiplier: 1.0,
    agility_multiplier: 1.4,
    luck_multiplier: 1.2,
    can_equip_left_hand: true  # 二刀流可能
  },
  {
    name: '占い師',
    description: 'タロットカードで運命を操り、多彩な効果を発揮。',
    job_type: 'advanced',
    max_level: 70,
    exp_multiplier: 1.5,
    hp_multiplier: 1.0,
    mp_multiplier: 1.2,
    attack_multiplier: 1.0,
    defense_multiplier: 0.9,
    magic_attack_multiplier: 1.1,
    magic_defense_multiplier: 1.1,
    agility_multiplier: 1.1,
    luck_multiplier: 1.4
  },
  
  # 特殊職業
  {
    name: '海賊',
    description: '荒々しい戦闘スタイルで敵を圧倒する海の戦士。',
    job_type: 'special',
    max_level: 80,
    exp_multiplier: 1.8,
    hp_multiplier: 1.2,
    mp_multiplier: 0.9,
    attack_multiplier: 1.2,
    defense_multiplier: 1.1,
    magic_attack_multiplier: 0.8,
    magic_defense_multiplier: 0.9,
    agility_multiplier: 1.1,
    luck_multiplier: 1.2
  },
  {
    name: 'デスマスター',
    description: '死霊術を操り、闇の力で戦う禁断の職業。',
    job_type: 'special',
    max_level: 85,
    exp_multiplier: 2.0,
    hp_multiplier: 1.0,
    mp_multiplier: 1.3,
    attack_multiplier: 0.9,
    defense_multiplier: 0.9,
    magic_attack_multiplier: 1.3,
    magic_defense_multiplier: 1.2,
    agility_multiplier: 1.0,
    luck_multiplier: 1.1
  },
  {
    name: 'ガーディアン',
    description: '究極の守備職。仲間を守ることに特化したマスタークラス。',
    job_type: 'special',
    max_level: 90,
    exp_multiplier: 2.2,
    hp_multiplier: 1.4,
    mp_multiplier: 1.0,
    attack_multiplier: 0.8,
    defense_multiplier: 1.4,
    magic_attack_multiplier: 0.8,
    magic_defense_multiplier: 1.3,
    agility_multiplier: 0.8,
    luck_multiplier: 1.0
  },
  {
    name: 'ドラゴンテイマー',
    description: 'ドラゴンと心を通わせ、共に戦うマスタークラス。',
    job_type: 'special',
    max_level: 90,
    exp_multiplier: 2.3,
    hp_multiplier: 1.2,
    mp_multiplier: 1.2,
    attack_multiplier: 1.1,
    defense_multiplier: 1.1,
    magic_attack_multiplier: 1.2,
    magic_defense_multiplier: 1.2,
    agility_multiplier: 1.0,
    luck_multiplier: 1.1
  },
  {
    name: '天地雷鳴士',
    description: '天地の力を操り、雷鳴と共に戦う特殊な魔法職。',
    job_type: 'special',
    max_level: 90,
    exp_multiplier: 2.1,
    hp_multiplier: 1.0,
    mp_multiplier: 1.3,
    attack_multiplier: 0.9,
    defense_multiplier: 0.9,
    magic_attack_multiplier: 1.3,
    magic_defense_multiplier: 1.2,
    agility_multiplier: 1.1,
    luck_multiplier: 1.2
  }
]

# ドラクエ10職業の作成
dq10_job_classes.each do |job_data|
  job = JobClass.find_or_create_by!(name: job_data[:name]) do |j|
    j.description = job_data[:description]
    j.job_type = job_data[:job_type]
    j.max_level = job_data[:max_level]
    j.exp_multiplier = job_data[:exp_multiplier]
    j.hp_multiplier = job_data[:hp_multiplier]
    j.mp_multiplier = job_data[:mp_multiplier]
    j.attack_multiplier = job_data[:attack_multiplier]
    j.defense_multiplier = job_data[:defense_multiplier]
    j.magic_attack_multiplier = job_data[:magic_attack_multiplier]
    j.magic_defense_multiplier = job_data[:magic_defense_multiplier]
    j.agility_multiplier = job_data[:agility_multiplier]
    j.luck_multiplier = job_data[:luck_multiplier]
    j.can_equip_left_hand = job_data[:can_equip_left_hand] || false
    j.active = true
  end
  
  # 既存の職業の二刀流設定も更新
  if job_data[:can_equip_left_hand] && !job.can_equip_left_hand
    job.update!(can_equip_left_hand: true)
  end
end

puts "ドラクエ10全職業を作成・更新しました"
puts "基本職: #{JobClass.basic.count}種類"
puts "上級職: #{JobClass.advanced.count}種類"
puts "特殊職: #{JobClass.special.count}種類"
puts "総職業数: #{JobClass.count}種類"