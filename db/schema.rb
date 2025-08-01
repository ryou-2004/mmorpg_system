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

ActiveRecord::Schema[8.0].define(version: 2025_08_01_135525) do
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

  create_table "characters", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.integer "gold", default: 1000, null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_job_class_id"
    t.index ["active"], name: "index_characters_on_active"
    t.index ["current_job_class_id"], name: "index_characters_on_current_job_class_id"
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
    t.index ["active"], name: "index_items_on_active"
    t.index ["item_type"], name: "index_items_on_item_type"
    t.index ["rarity"], name: "index_items_on_rarity"
    t.index ["sale_type"], name: "index_items_on_sale_type"
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
    t.index ["active"], name: "index_job_classes_on_active"
    t.index ["job_type"], name: "index_job_classes_on_job_type"
    t.index ["name"], name: "index_job_classes_on_name", unique: true
  end

  create_table "player_items", force: :cascade do |t|
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
    t.integer "player_warehouse_id"
    t.integer "bazaar_listing_id"
    t.index ["bazaar_listing_id"], name: "index_player_items_on_bazaar_listing_id"
    t.index ["character_id", "item_id"], name: "index_player_items_on_character_id_and_item_id"
    t.index ["character_id", "location", "player_warehouse_id"], name: "idx_player_items_location_warehouse"
    t.index ["character_id", "location", "status"], name: "idx_player_items_location_status"
    t.index ["character_id", "location"], name: "index_player_items_on_character_id_and_location"
    t.index ["character_id", "status"], name: "index_player_items_on_character_id_and_status"
    t.index ["character_id"], name: "index_player_items_on_character_id"
    t.index ["equipped"], name: "index_player_items_on_equipped"
    t.index ["item_id"], name: "index_player_items_on_item_id"
    t.index ["location", "player_warehouse_id"], name: "idx_player_items_warehouse_location"
    t.index ["locked"], name: "index_player_items_on_locked"
    t.index ["player_warehouse_id"], name: "index_player_items_on_player_warehouse_id"
  end

  create_table "player_job_classes", force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "job_class_id", null: false
    t.integer "level", default: 1, null: false
    t.integer "experience", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "unlocked_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "skill_points", default: 0, null: false
    t.index ["active"], name: "index_player_job_classes_on_active"
    t.index ["character_id", "job_class_id"], name: "index_player_job_classes_on_character_id_and_job_class_id", unique: true
    t.index ["character_id"], name: "index_player_job_classes_on_character_id"
    t.index ["job_class_id"], name: "index_player_job_classes_on_job_class_id"
    t.index ["level"], name: "index_player_job_classes_on_level"
  end

  create_table "player_warehouses", force: :cascade do |t|
    t.integer "character_id", null: false
    t.string "name"
    t.integer "max_slots"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_player_warehouses_on_character_id"
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
  add_foreign_key "characters", "player_job_classes", column: "current_job_class_id"
  add_foreign_key "characters", "users"
  add_foreign_key "player_items", "characters"
  add_foreign_key "player_items", "items"
  add_foreign_key "player_items", "player_warehouses"
  add_foreign_key "player_job_classes", "characters"
  add_foreign_key "player_job_classes", "job_classes"
  add_foreign_key "player_warehouses", "characters"
end
