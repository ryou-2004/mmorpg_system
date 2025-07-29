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
