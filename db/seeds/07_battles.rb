# Battle System Sample Data

puts "Creating battles..."

# Get some characters for battle data
characters = Character.limit(6)

if characters.count < 2
  puts "スキップ: 戦闘データ作成には最低2人のキャラクターが必要です"
  return
end

# Create sample battles
5.times do |i|
  battle = Battle.create!(
    battle_type: Battle.battle_types.keys.sample,
    status: :completed,
    start_time: rand(1..30).days.ago,
    end_time: rand(5..120).minutes.ago,
    location: [ "フィールド", "ダンジョン", "闘技場", "ボス部屋", "訓練場" ].sample,
    difficulty_level: rand(1..10),
    total_damage: 0,
    winner: characters.sample
  )

  # Add participants
  participants_count = rand(2..4)
  selected_chars = characters.sample(participants_count)

  total_damage = 0

  selected_chars.each_with_index do |char, idx|
    damage_dealt = rand(100..2000)
    damage_received = rand(50..1500)
    total_damage += damage_dealt

    participant = BattleParticipant.create!(
      battle: battle,
      character: char,
      role: BattleParticipant.roles.keys.sample,
      initial_stats: {
        hp: char.max_hp,
        mp: char.max_mp,
        attack: char.attack,
        defense: char.defense
      }.to_json,
      final_stats: {
        hp: [ char.max_hp - damage_received, 0 ].max,
        mp: rand(0..char.max_mp),
        attack: char.attack,
        defense: char.defense
      }.to_json,
      damage_dealt: damage_dealt,
      damage_received: damage_received,
      actions_taken: rand(5..25),
      survived: rand > 0.2
    )

    # Create battle logs for this participant
    action_count = rand(5..15)
    action_count.times do |action_idx|
      opponent = selected_chars.reject { |c| c.id == char.id }.sample

      BattleLog.create!(
        battle: battle,
        attacker: char,
        defender: opponent,
        action_type: BattleLog.action_types.keys.sample,
        damage_value: rand(0..300),
        critical_hit: rand > 0.85,
        skill_name: [ "斬撃", "魔法弾", "回復", "バフ", "必殺技" ].sample,
        calculation_details: {
          base_damage: rand(100..200),
          multiplier: rand(0.8..1.5).round(2),
          critical_multiplier: 1.5,
          defense_reduction: rand(0..50)
        }.to_json,
        occurred_at: battle.start_time + rand(60..3600).seconds
      )
    end
  end

  # Update battle total damage
  battle.update!(total_damage: total_damage, battle_duration: (battle.end_time - battle.start_time).to_i / 60)
end

puts "✓ 5件の戦闘データを作成しました"
puts "✓ 戦闘参加者データを作成しました"
puts "✓ 戦闘ログデータを作成しました"
