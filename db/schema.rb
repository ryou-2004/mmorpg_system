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

ActiveRecord::Schema[8.0].define(version: 2025_08_04_144115) do
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
    t.integer "unlock_level", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_class_id", "skill_line_id"], name: "index_job_class_skill_lines_unique", unique: true
    t.index ["job_class_id"], name: "index_job_class_skill_lines_on_job_class_id"
    t.index ["skill_line_id"], name: "index_job_class_skill_lines_on_skill_line_id"
    t.index ["unlock_level"], name: "index_job_class_skill_lines_on_unlock_level"
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
    t.integer "position_x", default: 0
    t.integer "position_y", default: 0
    t.integer "skill_line_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_skill_nodes_on_active"
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
  add_foreign_key "character_items", "character_warehouses"
  add_foreign_key "character_items", "characters"
  add_foreign_key "character_items", "items"
  add_foreign_key "character_job_classes", "characters"
  add_foreign_key "character_job_classes", "job_classes"
  add_foreign_key "character_skills", "characters"
  add_foreign_key "character_skills", "job_classes"
  add_foreign_key "character_skills", "skill_lines"
  add_foreign_key "character_warehouses", "characters"
  add_foreign_key "characters", "character_job_classes", column: "current_character_job_class_id"
  add_foreign_key "characters", "users"
  add_foreign_key "job_class_skill_lines", "job_classes"
  add_foreign_key "job_class_skill_lines", "skill_lines"
  add_foreign_key "skill_nodes", "skill_lines"
end
