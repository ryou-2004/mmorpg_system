# キャラクターに基本職業を割り当て
warrior_job = JobClass.find_by!(name: '戦士')
mage_job = JobClass.find_by!(name: '魔法使い')
priest_job = JobClass.find_by!(name: '僧侶')
thief_job = JobClass.find_by!(name: '盗賊')

# キャラクターと職業の組み合わせを定義
character_job_data = [
  # 田中太郎のキャラクター
  { user_email: 'player1@example.com', name: 'アキラ', gold: 5000, jobs: [ warrior_job, priest_job ] },
  { user_email: 'player1@example.com', name: 'アキラ２号', gold: 3000, jobs: [ mage_job ] },
  { user_email: 'player1@example.com', name: 'アキラ３号', gold: 2000, jobs: [ thief_job ] },

  # 佐藤花子のキャラクター
  { user_email: 'player2@example.com', name: 'ユウキ', gold: 8000, jobs: [ warrior_job ] },
  { user_email: 'player2@example.com', name: 'ユウキちゃん', gold: 4000, jobs: [ priest_job, mage_job ] },

  # 鈴木一郎のキャラクター
  { user_email: 'player3@example.com', name: 'サトシ', gold: 2500, jobs: [ thief_job ] },
  { user_email: 'player3@example.com', name: 'サトシJr', gold: 1500, jobs: [ warrior_job ] },
  { user_email: 'player3@example.com', name: 'イチロー', gold: 3500, jobs: [ mage_job, priest_job ] },

  # 山田テストのキャラクター
  { user_email: 'tester@example.com', name: 'テストキャラ', gold: 10000, jobs: [ warrior_job, mage_job, priest_job, thief_job ] },
  { user_email: 'tester@example.com', name: 'テストキャラ２', gold: 5000, jobs: [ warrior_job, mage_job ] },

  # John Smithのキャラクター
  { user_email: 'john@example.com', name: 'John', gold: 4500, jobs: [ warrior_job ] },
  { user_email: 'john@example.com', name: 'Johnny', gold: 3500, jobs: [ mage_job, priest_job ] },
  { user_email: 'john@example.com', name: 'J-man', gold: 6000, jobs: [ thief_job, warrior_job ] }
]

created_characters = []
character_job_data.each do |data|
  user = User.find_by!(email: data[:user_email])

  # そのユーザーのキャラクターの中で同じ名前がないかチェック
  character = user.characters.find_or_create_by!(name: data[:name]) do |c|
    c.gold = data[:gold]
    c.active = true
    c.skip_job_validation = true
  end

  # 職業を割り当て
  data[:jobs].each do |job|
    character.unlock_job!(job)
  end

  created_characters << character
end

puts "キャラクターデータと職業の割り当てが完了しました"
puts "総ユーザー数: #{User.count}"
puts "総キャラクター数: #{Character.count}"
puts "総職業習得数: #{CharacterJobClass.count}"
