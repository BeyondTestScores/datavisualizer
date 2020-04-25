# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_18_214620) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "blurb"
    t.text "description"
    t.boolean "administrative_measure", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "text"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.string "option4"
    t.string "option5"
    t.integer "kind"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "school_tree_categories", force: :cascade do |t|
    t.bigint "tree_category_id", null: false
    t.bigint "school_id", null: false
    t.integer "response_count"
    t.integer "answer_index_total"
    t.float "zscore"
    t.float "nonlikert"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_school_tree_categories_on_school_id"
    t.index ["tree_category_id"], name: "index_school_tree_categories_on_tree_category_id"
  end

  create_table "school_tree_category_questions", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.bigint "tree_category_question_id", null: false
    t.string "survey_monkey_page_id"
    t.string "survey_monkey_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["survey_id"], name: "index_school_tree_category_questions_on_survey_id"
    t.index ["tree_category_question_id"], name: "index_sctq_on_tcqid"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "surveys", force: :cascade do |t|
    t.string "name"
    t.bigint "tree_id"
    t.string "survey_monkey_id"
    t.integer "kind"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tree_id"], name: "index_surveys_on_tree_id"
  end

  create_table "tree_categories", force: :cascade do |t|
    t.bigint "tree_id", null: false
    t.bigint "category_id", null: false
    t.integer "parent_tree_category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_tree_categories_on_category_id"
    t.index ["tree_id"], name: "index_tree_categories_on_tree_id"
  end

  create_table "tree_category_questions", force: :cascade do |t|
    t.bigint "tree_category_id", null: false
    t.bigint "question_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_tree_category_questions_on_question_id"
    t.index ["tree_category_id"], name: "index_tree_category_questions_on_tree_category_id"
  end

  create_table "trees", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.index ["slug"], name: "index_trees_on_slug", unique: true
  end

  add_foreign_key "school_tree_categories", "schools"
  add_foreign_key "school_tree_categories", "tree_categories"
  add_foreign_key "school_tree_category_questions", "surveys"
  add_foreign_key "school_tree_category_questions", "tree_category_questions"
  add_foreign_key "tree_categories", "categories"
  add_foreign_key "tree_categories", "trees"
  add_foreign_key "tree_category_questions", "questions"
  add_foreign_key "tree_category_questions", "tree_categories"
end
