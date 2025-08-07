# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_07_134402) do
  create_table "admin_permissions", force: :cascade do |t|
    t.integer "admin_user_id", null: false
    t.string "resource_type", null: false
    t.integer "resource_id"
    t.string "action", null: false
    t.datetime "granted_at", null: false
    t.integer "granted_by_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_admin_permissions_on_active"
    t.index ["admin_user_id", "resource_type", "action"], name: "idx_on_admin_user_id_resource_type_action_b6cdfbb790"
    t.index ["admin_user_id"], name: "index_admin_permissions_on_admin_user_id"
    t.index ["granted_by_id"], name: "index_admin_permissions_on_granted_by_id"
    t.index ["resource_type", "resource_id"], name: "index_admin_permissions_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name", null: false
    t.string "role", default: "admin", null: false
    t.datetime "last_login_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_admin_users_on_active"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["role"], name: "index_admin_users_on_role"
  end

  create_table "battle_logs", force: :cascade do |t|
    t.integer "battle_id", null: false
    t.integer "attacker_id"
    t.integer "defender_id"
    t.integer "action_type", null: false
    t.integer "damage_value", default: 0
    t.boolean "critical_hit", default: false
    t.string "skill_name"
    t.text "calculation_details"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_battle_logs_on_action_type"
    t.index ["attacker_id"], name: "index_battle_logs_on_attacker_id"
    t.index ["battle_id", "occurred_at"], name: "index_battle_logs_on_battle_id_and_occurred_at"
    t.index ["battle_id"], name: "index_battle_logs_on_battle_id"
    t.index ["critical_hit"], name: "index_battle_logs_on_critical_hit"
    t.index ["defender_id"], name: "index_battle_logs_on_defender_id"
  end

  create_table "battle_participants", force: :cascade do |t|
    t.integer "battle_id", null: false
    t.integer "character_id", null: false
    t.integer "role"
    t.text "initial_stats"
    t.text "final_stats"
    t.integer "damage_dealt"
    t.integer "damage_received"
    t.integer "actions_taken"
    t.boolean "survived"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["battle_id"], name: "index_battle_participants_on_battle_id"
    t.index ["character_id"], name: "index_battle_participants_on_character_id"
  end

  create_table "battles", force: :cascade do |t|
    t.integer "battle_type", null: false
    t.integer "status", default: 0, null: false
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.string "location"
    t.integer "difficulty_level", default: 1
    t.integer "total_damage", default: 0
    t.integer "battle_duration"
    t.integer "winner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "participants_count", default: 0
    t.index ["battle_type"], name: "index_battles_on_battle_type"
    t.index ["start_time"], name: "index_battles_on_start_time"
    t.index ["status"], name: "index_battles_on_status"
    t.index ["winner_id"], name: "index_battles_on_winner_id"
  end

  create_table "character_items", force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "item_id", null: false
    t.integer "quantity", default: 1
    t.boolean "equipped", default: false
    t.integer "durability"
    t.integer "max_durability"
    t.integer "enchantment_level", default: 0
    t.datetime "obtained_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location", default: "inventory", null: false
    t.string "status", default: "available", null: false
    t.boolean "locked", default: false, null: false
    t.integer "character_warehouse_id"
    t.integer "bazaar_listing_id"
    t.string "equipment_slot"
    t.index ["bazaar_listing_id"], name: "index_character_items_on_bazaar_listing_id"
    t.index ["character_id", "equipment_slot"], name: "index_character_items_on_character_equipment_slot", unique: true, where: "location = 'equipped' AND equipment_slot IS NOT NULL"
    t.index ["character_id", "item_id"], name: "index_character_items_on_character_id_and_item_id"
    t.index ["character_id", "location", "character_warehouse_id"], name: "idx_player_items_location_warehouse"
    t.index ["character_id", "location", "status"], name: "idx_player_items_location_status"
    t.index ["character_id", "location"], name: "index_character_items_on_character_id_and_location"
    t.index ["character_id", "status"], name: "index_character_items_on_character_id_and_status"
    t.index ["character_id"], name: "index_character_items_on_character_id"
    t.index ["character_warehouse_id"], name: "index_character_items_on_character_warehouse_id"
    t.index ["equipment_slot"], name: "index_character_items_on_equipment_slot"
    t.index ["equipped"], name: "index_character_items_on_equipped"
    t.index ["item_id"], name: "index_character_items_on_item_id"
    t.index ["location", "character_warehouse_id"], name: "idx_player_items_warehouse_location"
    t.index ["locked"], name: "index_character_items_on_locked"
  end

  create_table "character_job_classes", force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "job_class_id", null: false
    t.integer "level", default: 1, null: false
    t.integer "experience", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "unlocked_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "skill_points", default: 0, null: false
    t.integer "total_skill_points", default: 0, null: false
    t.index ["active"], name: "index_character_job_classes_on_active"
    t.index ["character_id", "job_class_id"], name: "index_character_job_classes_on_character_id_and_job_class_id", unique: true
    t.index ["character_id"], name: "index_character_job_classes_on_character_id"
    t.index ["job_class_id"], name: "index_character_job_classes_on_job_class_id"
    t.index ["level"], name: "index_character_job_classes_on_level"
  end

  create_table "character_quests", force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "quest_id", null: false
    t.string "status", default: "started", null: false
    t.datetime "started_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "completed_at"
    t.json "progress", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "quest_id"], name: "index_character_quests_on_character_id_and_quest_id", unique: true
    t.index ["character_id"], name: "index_character_quests_on_character_id"
    t.index ["completed_at"], name: "index_character_quests_on_completed_at"
    t.index ["quest_id"], name: "index_character_quests_on_quest_id"
    t.index ["started_at"], name: "index_character_quests_on_started_at"
    t.index ["status"], name: "index_character_quests_on_status"
  end

  create_table "character_skills", force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "job_class_id", null: false
    t.integer "skill_line_id", null: false
    t.integer "points_invested", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "job_class_id", "skill_line_id"], name: "index_character_skills_unique", unique: true
    t.index ["character_id", "job_class_id"], name: "index_character_skills_on_character_id_and_job_class_id"
    t.index ["character_id"], name: "index_character_skills_on_character_id"
    t.index ["job_class_id"], name: "index_character_skills_on_job_class_id"
    t.index ["skill_line_id"], name: "index_character_skills_on_skill_line_id"
  end

  create_table "character_warehouses", force: :cascade do |t|
    t.integer "character_id", null: false
    t.string "name"
    t.integer "max_slots"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_warehouses_on_character_id"
  end

  create_table "characters", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.integer "gold", default: 1000, null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_character_job_class_id"
    t.index ["active"], name: "index_characters_on_active"
    t.index ["current_character_job_class_id"], name: "index_characters_on_current_character_job_class_id"
    t.index ["user_id", "name"], name: "index_characters_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "item_type"
    t.string "rarity"
    t.integer "max_stack", default: 1
    t.integer "buy_price", default: 0
    t.integer "sell_price", default: 0
    t.integer "level_requirement", default: 1
    t.json "job_requirement", default: []
    t.json "effects", default: []
    t.string "icon_path"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sale_type", default: "shop"
    t.string "equipment_slot"
    t.string "type"
    t.string "weapon_category"
    t.string "armor_category"
    t.string "accessory_category"
    t.index ["accessory_category"], name: "index_items_on_accessory_category"
    t.index ["active"], name: "index_items_on_active"
    t.index ["armor_category"], name: "index_items_on_armor_category"
    t.index ["item_type"], name: "index_items_on_item_type"
    t.index ["rarity"], name: "index_items_on_rarity"
    t.index ["sale_type"], name: "index_items_on_sale_type"
    t.index ["type"], name: "index_items_on_type"
    t.index ["weapon_category"], name: "index_items_on_weapon_category"
  end

  create_table "job_class_skill_lines", force: :cascade do |t|
    t.integer "job_class_id", null: false
    t.integer "skill_line_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.index ["job_class_id", "skill_line_id"], name: "index_job_class_skill_lines_unique", unique: true
    t.index ["job_class_id"], name: "index_job_class_skill_lines_on_job_class_id"
    t.index ["skill_line_id"], name: "index_job_class_skill_lines_on_skill_line_id"
  end

  create_table "job_class_weapons", force: :cascade do |t|
    t.integer "job_class_id", null: false
    t.string "weapon_category", null: false
    t.integer "unlock_level", default: 1, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_class_id", "weapon_category"], name: "index_job_class_weapons_on_job_class_id_and_weapon_category", unique: true
    t.index ["job_class_id"], name: "index_job_class_weapons_on_job_class_id"
  end

  create_table "job_classes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "job_type", null: false
    t.integer "max_level", default: 50, null: false
    t.decimal "exp_multiplier", precision: 3, scale: 1, default: "1.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "base_hp", default: 100, null: false
    t.integer "base_mp", default: 50, null: false
    t.integer "base_attack", default: 10, null: false
    t.integer "base_defense", default: 10, null: false
    t.integer "base_magic_attack", default: 10, null: false
    t.integer "base_magic_defense", default: 10, null: false
    t.integer "base_agility", default: 10, null: false
    t.integer "base_luck", default: 10, null: false
    t.decimal "hp_multiplier", precision: 3, scale: 2, default: "1.0", null: false
    t.decimal "mp_multiplier", precision: 3, scale: 2, default: "1.0", null: false
    t.decimal "attack_multiplier", precision: 3, scale: 2, default: "1.0", null: false
    t.decimal "defense_multiplier", precision: 3, scale: 2, default: "1.0", null: false
    t.decimal "magic_attack_multiplier", precision: 3, scale: 2, default: "1.0", null: false
    t.decimal "magic_defense_multiplier", precision: 3, scale: 2, default: "1.0", null: false
    t.decimal "agility_multiplier", precision: 3, scale: 2, default: "1.0", null: false
    t.decimal "luck_multiplier", precision: 3, scale: 2, default: "1.0", null: false
    t.boolean "can_equip_left_hand", default: false, null: false
    t.index ["active"], name: "index_job_classes_on_active"
    t.index ["can_equip_left_hand"], name: "index_job_classes_on_can_equip_left_hand"
    t.index ["job_type"], name: "index_job_classes_on_job_type"
    t.index ["name"], name: "index_job_classes_on_name", unique: true
  end

  create_table "quest_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.integer "display_order", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_quest_categories_on_active"
    t.index ["display_order"], name: "index_quest_categories_on_display_order"
  end

  create_table "quest_rewards", force: :cascade do |t|
    t.integer "quest_id", null: false
    t.string "reward_type", null: false
    t.string "reward_item_type"
    t.integer "reward_item_id"
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quest_id"], name: "index_quest_rewards_on_quest_id"
    t.index ["reward_item_id"], name: "index_quest_rewards_on_reward_item_id"
    t.index ["reward_item_type"], name: "index_quest_rewards_on_reward_item_type"
    t.index ["reward_type"], name: "index_quest_rewards_on_reward_type"
  end

  create_table "quests", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "quest_type", null: false
    t.integer "level_requirement", default: 1, null: false
    t.integer "experience_reward", default: 0, null: false
    t.integer "gold_reward", default: 0, null: false
    t.string "status", default: "available", null: false
    t.boolean "active", default: true, null: false
    t.integer "prerequisite_quest_id"
    t.integer "display_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "item_rewards", default: []
    t.integer "skill_point_reward", default: 0, null: false
    t.integer "quest_category_id"
    t.integer "display_number"
    t.index ["active"], name: "index_quests_on_active"
    t.index ["display_order"], name: "index_quests_on_display_order"
    t.index ["level_requirement"], name: "index_quests_on_level_requirement"
    t.index ["prerequisite_quest_id"], name: "index_quests_on_prerequisite_quest_id"
    t.index ["quest_category_id"], name: "index_quests_on_quest_category_id"
    t.index ["quest_type", "display_number"], name: "index_quests_on_quest_type_and_display_number", unique: true, where: "display_number IS NOT NULL"
    t.index ["quest_type"], name: "index_quests_on_quest_type"
    t.index ["status"], name: "index_quests_on_status"
  end

  create_table "shop_items", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.integer "item_id", null: false
    t.integer "stock_quantity", default: 0
    t.boolean "unlimited_stock", default: false, null: false
    t.boolean "active", default: true, null: false
    t.integer "display_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_shop_items_on_active"
    t.index ["display_order"], name: "index_shop_items_on_display_order"
    t.index ["item_id"], name: "index_shop_items_on_item_id"
    t.index ["shop_id", "item_id"], name: "index_shop_items_on_shop_id_and_item_id", unique: true
    t.index ["shop_id"], name: "index_shop_items_on_shop_id"
    t.index ["unlimited_stock"], name: "index_shop_items_on_unlimited_stock"
  end

  create_table "shops", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "shop_type", null: false
    t.string "location"
    t.string "npc_name"
    t.boolean "active", default: true, null: false
    t.integer "display_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_shops_on_active"
    t.index ["display_order"], name: "index_shops_on_display_order"
    t.index ["location"], name: "index_shops_on_location"
    t.index ["name"], name: "index_shops_on_name", unique: true
    t.index ["shop_type"], name: "index_shops_on_shop_type"
  end

  create_table "skill_lines", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "skill_line_type", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_skill_lines_on_active"
    t.index ["skill_line_type"], name: "index_skill_lines_on_skill_line_type"
  end

  create_table "skill_nodes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "node_type", null: false
    t.integer "points_required", default: 1, null: false
    t.text "effects"
    t.integer "skill_line_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "display_order", default: 0, null: false
    t.index ["active"], name: "index_skill_nodes_on_active"
    t.index ["display_order"], name: "index_skill_nodes_on_display_order"
    t.index ["node_type"], name: "index_skill_nodes_on_node_type"
    t.index ["skill_line_id"], name: "index_skill_nodes_on_skill_line_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "admin_permissions", "admin_users"
  add_foreign_key "admin_permissions", "admin_users", column: "granted_by_id"
  add_foreign_key "battle_logs", "battles"
  add_foreign_key "battle_logs", "characters", column: "attacker_id"
  add_foreign_key "battle_logs", "characters", column: "defender_id"
  add_foreign_key "battle_participants", "battles"
  add_foreign_key "battle_participants", "characters"
  add_foreign_key "battles", "characters", column: "winner_id"
  add_foreign_key "character_items", "character_warehouses"
  add_foreign_key "character_items", "characters"
  add_foreign_key "character_items", "items"
  add_foreign_key "character_job_classes", "characters"
  add_foreign_key "character_job_classes", "job_classes"
  add_foreign_key "character_quests", "characters"
  add_foreign_key "character_quests", "quests"
  add_foreign_key "character_skills", "characters"
  add_foreign_key "character_skills", "job_classes"
  add_foreign_key "character_skills", "skill_lines"
  add_foreign_key "character_warehouses", "characters"
  add_foreign_key "characters", "character_job_classes", column: "current_character_job_class_id"
  add_foreign_key "characters", "users"
  add_foreign_key "job_class_skill_lines", "job_classes"
  add_foreign_key "job_class_skill_lines", "skill_lines"
  add_foreign_key "job_class_weapons", "job_classes"
  add_foreign_key "quest_rewards", "quests"
  add_foreign_key "quests", "quest_categories", on_delete: :nullify
  add_foreign_key "quests", "quests", column: "prerequisite_quest_id"
  add_foreign_key "shop_items", "items"
  add_foreign_key "shop_items", "shops"
  add_foreign_key "skill_nodes", "skill_lines"
end
