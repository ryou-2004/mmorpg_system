namespace :enemy_spawn do
  desc "Migrate existing enemy spawns to regions"
  task migrate_to_regions: :environment do
    puts "Starting enemy spawn region migration..."
    
    # Define location-to-region mappings
    location_mappings = {
      "始まりの草原" => "E1",      # 始まりの村
      "平和な森" => "F1",         # 平和な森 (exact match)
      "ゴブリンの森" => "B3",     # 古老の森
      "山道" => "C1",            # なだらかな丘陵
      "竜の峡谷" => "C5",        # 炎の山
      "呪われた墓場" => "E7",     # 廃墟の街
      "オークの砦" => "E6",      # 古城
      "天空の祭壇" => "D7",      # 虚無の神殿
      "訓練場" => "E1",          # 始まりの村
      "幸運の泉" => "F5",        # 水晶湖
      "森の奥地" => "F4",        # ささやきの森
      "古い遺跡" => "B2",        # 古代遺跡
      "スライムの王国" => "F8"   # 呪いの湖
    }
    
    continent = Continent.find_by(name: "astoltea")
    unless continent
      puts "ERROR: Astoltea continent not found!"
      exit 1
    end
    
    updated_count = 0
    failed_count = 0
    
    EnemySpawn.where(region_id: nil).find_each do |enemy_spawn|
      coordinate = location_mappings[enemy_spawn.location]
      
      if coordinate
        grid_x = coordinate[0]
        grid_y = coordinate[1..-1].to_i
        region = continent.regions.find_by(grid_x: grid_x, grid_y: grid_y)
        if region
          enemy_spawn.update!(region: region, continent: continent)
          puts "✓ Updated #{enemy_spawn.location} → #{region.coordinate} (#{region.display_name})"
          updated_count += 1
        else
          puts "✗ Region not found for coordinate #{coordinate} (#{enemy_spawn.location})"
          failed_count += 1
        end
      else
        puts "✗ No mapping found for location: #{enemy_spawn.location}"
        failed_count += 1
      end
    end
    
    puts "\nMigration completed!"
    puts "Updated: #{updated_count}"
    puts "Failed: #{failed_count}"
    
    # Display updated enemy spawns
    puts "\nUpdated enemy spawns:"
    EnemySpawn.joins(:region, :enemy).each do |es|
      puts "  #{es.enemy.name} in #{es.region.coordinate} (#{es.region.display_name})"
    end
  end

  desc "Rollback enemy spawn region migration"
  task rollback_regions: :environment do
    puts "Rolling back enemy spawn region migration..."
    
    updated_count = EnemySpawn.where.not(region_id: nil).update_all(region_id: nil, continent_id: nil)
    puts "Rolled back #{updated_count} enemy spawns"
  end
end