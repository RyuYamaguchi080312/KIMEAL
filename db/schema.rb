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

ActiveRecord::Schema[8.0].define(version: 2026_06_22_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "daily_selections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recipe_id", null: false
    t.date "selected_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_daily_selections_on_recipe_id"
    t.index ["user_id", "selected_on"], name: "index_daily_selections_on_user_id_and_selected_on", unique: true
    t.index ["user_id"], name: "index_daily_selections_on_user_id"
  end

  create_table "recipe_impressions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recipe_id", null: false
    t.datetime "displayed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_impressions_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_recipe_impressions_on_user_id_and_recipe_id"
    t.index ["user_id"], name: "index_recipe_impressions_on_user_id"
  end

  create_table "recipe_tags", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "tag_id"], name: "index_recipe_tags_on_recipe_id_and_tag_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_tags_on_recipe_id"
    t.index ["tag_id"], name: "index_recipe_tags_on_tag_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "image_url"
    t.text "ingredients"
    t.text "instructions"
    t.integer "cooking_time"
    t.integer "source_type", default: 0, null: false
    t.string "external_id"
    t.string "source_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_recipes_on_category_id"
  end

  create_table "swipes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recipe_id", null: false
    t.integer "direction", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_swipes_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_swipes_on_user_id_and_recipe_id"
    t.index ["user_id"], name: "index_swipes_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "daily_selections", "recipes"
  add_foreign_key "daily_selections", "users"
  add_foreign_key "recipe_impressions", "recipes"
  add_foreign_key "recipe_impressions", "users"
  add_foreign_key "recipe_tags", "recipes"
  add_foreign_key "recipe_tags", "tags"
  add_foreign_key "recipes", "categories"
  add_foreign_key "swipes", "recipes"
  add_foreign_key "swipes", "users"
end
