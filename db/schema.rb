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

ActiveRecord::Schema.define(version: 2022_11_22_065513) do

  create_table "external_service_definitions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "user_oauth", null: false
    t.integer "active", null: false
    t.string "description", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "external_service_parameter_definitions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "external_service_definition_id"
    t.string "name"
    t.string "key"
    t.integer "input_type"
    t.string "description"
    t.integer "is_required", null: false
    t.integer "is_encrypted", null: false
    t.integer "is_displayed", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_service_definition_id"], name: "external_service_definition_id"
  end

  create_table "external_service_paramters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "external_service_id"
    t.bigint "external_service_parameter_definition_id"
    t.text "parameter_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["external_service_id"], name: "external_service_id"
    t.index ["external_service_parameter_definition_id"], name: "external_service_parameter_definition_id"
  end

  create_table "external_services", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "linkage_system_id"
    t.bigint "external_service_definition_id"
    t.integer "created_by", null: false
    t.integer "updated_by", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["external_service_definition_id"], name: "external_service_definition_id"
    t.index ["linkage_system_id"], name: "index_external_services_on_linkage_system_id"
  end

  create_table "facebook_credentials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "app_id"
    t.string "app_secret"
    t.text "access_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "linkage_systems", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "label", null: false
    t.integer "linkage_application_type", default: 5
    t.integer "status", default: 0, null: false
    t.text "error_message"
    t.integer "created_by"
    t.integer "updated_by"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "modified_at"
    t.datetime "deleted_at"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "external_service_parameter_definitions", "external_service_definitions"
  add_foreign_key "external_service_paramters", "external_service_parameter_definitions"
  add_foreign_key "external_service_paramters", "external_services"
  add_foreign_key "external_services", "external_service_definitions"
  add_foreign_key "external_services", "linkage_systems"
end
