# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 管理者アカウントの作成
AdminUser.find_or_create_by!(email: 'admin@mmorpg.local') do |admin|
  admin.name = 'システム管理者'
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
  admin.role = 'super_admin'
  admin.active = true
end

AdminUser.find_or_create_by!(email: 'moderator@mmorpg.local') do |admin|
  admin.name = 'モデレーター'
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
  admin.role = 'moderator'
  admin.active = true
end

puts "管理者アカウントを作成しました"
puts "Super Admin: admin@mmorpg.local / password123"
puts "Moderator: moderator@mmorpg.local / password123"

# 基本職業の作成
basic_jobs = [
  {
    name: '戦士',
    description: '剣と盾を使った近接戦闘のエキスパート。高い体力と防御力を持つ。',
    job_type: 'basic',
    required_level: 1,
    max_level: 50,
    exp_multiplier: 1.0
  },
  {
    name: '魔法使い',
    description: '強力な攻撃魔法を操る魔術師。高い魔力を持つが体力は低い。',
    job_type: 'basic',
    required_level: 1,
    max_level: 50,
    exp_multiplier: 1.2
  },
  {
    name: '僧侶',
    description: '回復魔法と補助魔法のスペシャリスト。パーティの生命線。',
    job_type: 'basic',
    required_level: 1,
    max_level: 50,
    exp_multiplier: 1.1
  },
  {
    name: '盗賊',
    description: '素早い動きと隠密行動が得意。クリティカル攻撃に特化。',
    job_type: 'basic',
    required_level: 1,
    max_level: 50,
    exp_multiplier: 0.9
  }
]

basic_jobs.each do |job_data|
  JobClass.find_or_create_by!(name: job_data[:name]) do |job|
    job.description = job_data[:description]
    job.job_type = job_data[:job_type]
    job.required_level = job_data[:required_level]
    job.max_level = job_data[:max_level]
    job.exp_multiplier = job_data[:exp_multiplier]
  end
end

# 上級職業の作成
advanced_jobs = [
  {
    name: 'パラディン',
    description: '戦士の上位職。聖なる力を使い、仲間を守る騎士。',
    job_type: 'advanced',
    required_level: 20,
    max_level: 70,
    exp_multiplier: 1.5
  },
  {
    name: '賢者',
    description: '魔法使いと僧侶の技を併せ持つ上級魔術師。',
    job_type: 'advanced',
    required_level: 25,
    max_level: 70,
    exp_multiplier: 1.8
  },
  {
    name: 'アサシン',
    description: '盗賊の上位職。致命的な一撃で敵を葬る暗殺者。',
    job_type: 'advanced',
    required_level: 22,
    max_level: 65,
    exp_multiplier: 1.4
  }
]

advanced_jobs.each do |job_data|
  JobClass.find_or_create_by!(name: job_data[:name]) do |job|
    job.description = job_data[:description]
    job.job_type = job_data[:job_type]
    job.required_level = job_data[:required_level]
    job.max_level = job_data[:max_level]
    job.exp_multiplier = job_data[:exp_multiplier]
  end
end

# 特殊職業の作成
special_jobs = [
  {
    name: '魔剣士',
    description: '剣術と魔法を同時に扱う特殊な戦士。バランス型の万能職。',
    job_type: 'special',
    required_level: 30,
    max_level: 80,
    exp_multiplier: 2.0
  },
  {
    name: '召喚師',
    description: '精霊や魔獣を召喚して戦う特殊魔術師。',
    job_type: 'special',
    required_level: 35,
    max_level: 85,
    exp_multiplier: 2.2
  }
]

special_jobs.each do |job_data|
  JobClass.find_or_create_by!(name: job_data[:name]) do |job|
    job.description = job_data[:description]
    job.job_type = job_data[:job_type]
    job.required_level = job_data[:required_level]
    job.max_level = job_data[:max_level]
    job.exp_multiplier = job_data[:exp_multiplier]
  end
end

puts "職業データを作成しました"
puts "基本職: #{JobClass.basic.count}種類"
puts "上級職: #{JobClass.advanced.count}種類"
puts "特殊職: #{JobClass.special.count}種類"
