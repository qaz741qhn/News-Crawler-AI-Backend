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

ActiveRecord::Schema[7.0].define(version: 2023_06_08_024259) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "generated_histories", force: :cascade do |t|
    t.string "history_type"
    t.json "keywords"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_applications", force: :cascade do |t|
    t.string "education"
    t.text "experience"
    t.string "interested_role"
    t.text "company_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "abilities"
    t.text "professional_values_interests"
    t.text "soft_skills"
  end

  create_table "news", force: :cascade do |t|
    t.string "title"
    t.text "summary"
    t.text "content"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
  end

  create_table "visits", force: :cascade do |t|
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
