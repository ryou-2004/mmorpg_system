# サンプルユーザーの作成
sample_users = [
  {
    email: 'player1@example.com',
    name: '田中太郎'
  },
  {
    email: 'player2@example.com',
    name: '佐藤花子'
  },
  {
    email: 'player3@example.com',
    name: '鈴木一郎'
  },
  {
    email: 'tester@example.com',
    name: '山田テスト'
  },
  {
    email: 'john@example.com',
    name: 'John Smith'
  }
]

created_users = []
sample_users.each do |user_data|
  user = User.find_or_create_by!(email: user_data[:email]) do |u|
    u.name = user_data[:name]
    u.active = true
  end
  created_users << user
end

puts "ユーザーデータを作成しました: #{User.count}人"