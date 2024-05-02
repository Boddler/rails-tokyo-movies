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

ActiveRecord::Schema[7.0].define(version: 2024_05_02_011130) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cinemas", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.string "url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "schedule"
    t.string "encoding"
    t.string "map"
  end

  create_table "movies", force: :cascade do |t|
    t.string "name"
    t.string "web_title"
    t.string "language"
    t.integer "runtime"
    t.text "description"
    t.string "director"
    t.string "poster"
    t.string "backgrounds", default: [], array: true
    t.integer "year"
    t.float "popularity"
    t.string "cast", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hide", default: false
    t.integer "tmdb_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "showings", force: :cascade do |t|
    t.bigint "movie_id"
    t.bigint "cinema_id"
    t.date "date"
    t.string "times", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cinema_id"], name: "index_showings_on_cinema_id"
    t.index ["movie_id"], name: "index_showings_on_movie_id"
  end

  add_foreign_key "showings", "cinemas"
  add_foreign_key "showings", "movies"
end
