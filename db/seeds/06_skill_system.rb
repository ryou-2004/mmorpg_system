puts "Creating skill system data..."

# 武器スキルライン
weapon_skill_lines = [
  {
    name: "片手剣",
    description: "片手剣の技能を向上させ、より強力な剣技を習得します。",
    skill_line_type: "weapon"
  },
  {
    name: "両手剣",
    description: "両手剣の威力を最大限に活用し、強力な一撃を放つ技術を学びます。",
    skill_line_type: "weapon"
  },
  {
    name: "短剣",
    description: "素早い動きと正確な攻撃で敵を翻弄する短剣技術。",
    skill_line_type: "weapon"
  },
  {
    name: "弓",
    description: "遠距離から正確な射撃を行う弓術の技能。",
    skill_line_type: "weapon"
  },
  {
    name: "杖",
    description: "魔法の力を増幅し、より効果的な呪文を唱える技術。",
    skill_line_type: "weapon"
  },
  {
    name: "槍",
    description: "長いリーチを活かした槍術の技能を磨きます。",
    skill_line_type: "weapon"
  }
]

weapon_skill_lines.each do |skill_line_data|
  skill_line = SkillLine.find_or_create_by(name: skill_line_data[:name]) do |sl|
    sl.description = skill_line_data[:description]
    sl.skill_line_type = skill_line_data[:skill_line_type]
    sl.active = true
  end
  
  puts "  - Created weapon skill line: #{skill_line.name}"
end

# 職業専用スキルライン
job_specific_skills = [
  {
    name: "戦士の心得",
    description: "戦士としての基本的な戦闘技術と精神力を鍛えます。",
    skill_line_type: "job_specific"
  },
  {
    name: "魔法使いの知識",
    description: "魔法の理論と実践的な呪文詠唱技術を学びます。",
    skill_line_type: "job_specific"
  },
  {
    name: "僧侶の信仰",
    description: "神聖な力を操り、癒しと守護の技術を習得します。",
    skill_line_type: "job_specific"
  },
  {
    name: "盗賊の技巧",
    description: "隠密行動と巧妙な技術で敵を出し抜く能力を身につけます。",
    skill_line_type: "job_specific"
  }
]

job_specific_skills.each do |skill_line_data|
  skill_line = SkillLine.find_or_create_by(name: skill_line_data[:name]) do |sl|
    sl.description = skill_line_data[:description]
    sl.skill_line_type = skill_line_data[:skill_line_type]
    sl.active = true
  end
  
  puts "  - Created job-specific skill line: #{skill_line.name}"
end

# スキルノードの作成
skill_lines = SkillLine.all

skill_lines.each do |skill_line|
  next if skill_line.skill_nodes.exists?
  
  if skill_line.weapon_skill?
    # 武器スキルノード
    nodes = [
      {
        name: "基本熟練",
        description: "#{skill_line.name}の基本的な扱いに慣れ、攻撃力が向上します。",
        node_type: "stat_boost",
        points_required: 5,
        effects: { type: "stat_boost", stat: "attack", value: 3 }.to_json,
        position_x: 0,
        position_y: 0
      },
      {
        name: "上級熟練",
        description: "#{skill_line.name}の扱いに熟達し、さらに攻撃力が向上します。",
        node_type: "stat_boost",
        points_required: 15,
        effects: { type: "stat_boost", stat: "attack", value: 5 }.to_json,
        position_x: 1,
        position_y: 0
      },
      {
        name: "専門技",
        description: "#{skill_line.name}の特殊技を習得します。",
        node_type: "technique",
        points_required: 25,
        effects: { type: "technique", name: "#{skill_line.name}専門技", damage_multiplier: 1.5 }.to_json,
        position_x: 2,
        position_y: 0
      }
    ]
  else
    # 職業専用スキルノード
    nodes = [
      {
        name: "基本素養",
        description: "職業の基本的な能力を身につけます。",
        node_type: "stat_boost",
        points_required: 3,
        effects: { type: "stat_boost", stat: "hp", value: 10 }.to_json,
        position_x: 0,
        position_y: 0
      },
      {
        name: "専門知識",
        description: "職業の専門的な知識を習得します。",
        node_type: "stat_boost",
        points_required: 10,
        effects: { type: "stat_boost", stat: "mp", value: 8 }.to_json,
        position_x: 1,
        position_y: 0
      },
      {
        name: "奥義",
        description: "職業の奥義を会得します。",
        node_type: "passive",
        points_required: 20,
        effects: { type: "passive", name: "職業奥義", description: "特殊効果を発動" }.to_json,
        position_x: 2,
        position_y: 0
      }
    ]
  end
  
  nodes.each do |node_data|
    skill_line.skill_nodes.create!(node_data)
  end
  
  puts "    - Created skill nodes for: #{skill_line.name}"
end

# 職業とスキルラインの関連付け
job_classes = JobClass.all

job_classes.each do |job_class|
  case job_class.name
  when "戦士"
    skill_lines = [
      SkillLine.find_by(name: "片手剣"),
      SkillLine.find_by(name: "両手剣"),
      SkillLine.find_by(name: "戦士の心得")
    ]
  when "魔法使い"
    skill_lines = [
      SkillLine.find_by(name: "杖"),
      SkillLine.find_by(name: "短剣"),
      SkillLine.find_by(name: "魔法使いの知識")
    ]
  when "僧侶"
    skill_lines = [
      SkillLine.find_by(name: "杖"),
      SkillLine.find_by(name: "僧侶の信仰")
    ]
  when "盗賊"
    skill_lines = [
      SkillLine.find_by(name: "短剣"),
      SkillLine.find_by(name: "弓"),
      SkillLine.find_by(name: "盗賊の技巧")
    ]
  else
    # その他の職業は基本的なスキルラインを付与
    skill_lines = [
      SkillLine.find_by(name: "片手剣")
    ]
  end
  
  skill_lines.compact.each do |skill_line|
    JobClassSkillLine.find_or_create_by(
      job_class: job_class,
      skill_line: skill_line
    )
  end
  
  puts "  - Assigned skill lines to: #{job_class.name}"
end

# 既存キャラクターにスキルポイントを付与
CharacterJobClass.find_each do |character_job_class|
  if character_job_class.total_skill_points == 0
    # レベルに基づいてスキルポイントを計算
    skill_points = (character_job_class.level - 1) * 2 + 5
    character_job_class.update!(total_skill_points: skill_points)
    puts "  - Granted #{skill_points} skill points to #{character_job_class.character.name} (#{character_job_class.job_class.name})"
  end
end

puts "Skill system data creation completed!"