puts "PlayerStatを作成中..."

Player.find_each do |player|
  next if player.player_stat.present?

  # プレイヤーの最高レベル職業を取得
  primary_job = player.player_job_classes.order(level: :desc).first&.job_class
  job_name = primary_job&.name || '戦士'

  # 職業に基づいた初期ステータス設定
  base_stats = case job_name
  when '戦士'
                 {
                   level: rand(1..3),
                   hp: 120, max_hp: 120,
                   mp: 30, max_mp: 30,
                   attack: 15, defense: 15,
                   magic_attack: 5, magic_defense: 8,
                   agility: 8, luck: 8
                 }
  when '魔法使い'
                 {
                   level: rand(1..3),
                   hp: 80, max_hp: 80,
                   mp: 80, max_mp: 80,
                   attack: 6, defense: 6,
                   magic_attack: 18, magic_defense: 15,
                   agility: 10, luck: 12
                 }
  when '僧侶'
                 {
                   level: rand(1..3),
                   hp: 100, max_hp: 100,
                   mp: 70, max_mp: 70,
                   attack: 8, defense: 12,
                   magic_attack: 15, magic_defense: 18,
                   agility: 9, luck: 15
                 }
  when '盗賊'
                 {
                   level: rand(1..3),
                   hp: 90, max_hp: 90,
                   mp: 40, max_mp: 40,
                   attack: 12, defense: 8,
                   magic_attack: 8, magic_defense: 8,
                   agility: 18, luck: 16
                 }
  when '騎士'
                 {
                   level: rand(2..5),
                   hp: 140, max_hp: 140,
                   mp: 35, max_mp: 35,
                   attack: 14, defense: 20,
                   magic_attack: 6, magic_defense: 12,
                   agility: 7, luck: 9
                 }
  when '魔剣士'
                 {
                   level: rand(2..5),
                   hp: 110, max_hp: 110,
                   mp: 60, max_mp: 60,
                   attack: 13, defense: 10,
                   magic_attack: 13, magic_defense: 12,
                   agility: 12, luck: 10
                 }
  when 'パラディン'
                 {
                   level: rand(3..7),
                   hp: 160, max_hp: 160,
                   mp: 50, max_mp: 50,
                   attack: 12, defense: 22,
                   magic_attack: 8, magic_defense: 20,
                   agility: 6, luck: 12
                 }
  else
                 {
                   level: 1,
                   hp: 100, max_hp: 100,
                   mp: 50, max_mp: 50,
                   attack: 10, defense: 10,
                   magic_attack: 10, magic_defense: 10,
                   agility: 10, luck: 10
                 }
  end

  # レベルに応じた経験値設定
  exp_for_level = case base_stats[:level]
  when 1 then rand(0..99)
  when 2 then rand(100..249)
  when 3 then rand(250..449)
  when 4 then rand(450..699)
  when 5 then rand(700..999)
  when 6 then rand(1000..1349)
  when 7 then rand(1350..1749)
  else 0
  end

  # ステータスポイント設定（レベル-1 * 5 + ランダム）
  stat_points = (base_stats[:level] - 1) * 5 + rand(0..10)

  player_stat = player.create_player_stat!(
    level: base_stats[:level],
    experience: exp_for_level,
    hp: base_stats[:hp],
    max_hp: base_stats[:max_hp],
    mp: base_stats[:mp],
    max_mp: base_stats[:max_mp],
    attack: base_stats[:attack],
    defense: base_stats[:defense],
    magic_attack: base_stats[:magic_attack],
    magic_defense: base_stats[:magic_defense],
    agility: base_stats[:agility],
    luck: base_stats[:luck],
    stat_points: stat_points
  )

  puts "  #{player.name} (#{job_name}): Lv.#{player_stat.level} HP:#{player_stat.hp}/#{player_stat.max_hp} MP:#{player_stat.mp}/#{player_stat.max_mp} 戦闘力:#{player_stat.battle_power}"
end

puts "PlayerStatを作成しました:"
puts "- 総プレイヤー数: #{Player.count}"
puts "- PlayerStat作成数: #{PlayerStat.count}"

# 統計情報
levels = PlayerStat.group(:level).count
puts "- レベル分布: #{levels.sort.to_h}"

average_battle_power = PlayerStat.average(:level).to_f * 10
puts "- 平均戦闘力: #{average_battle_power.round(1)}"

puts ""
