class CreateSchools < ActiveRecord::Migration[6.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    create_table :school_tree_categories do |t|
      t.belongs_to :tree_category, null: false, foreign_key: true
      t.belongs_to :school, null: false, foreign_key: true
      t.integer :response_count
      t.integer :answer_index_total
      t.float :zscore
      t.float :nonlikert

      t.timestamps
    end

    create_table :school_tree_category_questions do |t|
      t.belongs_to :survey, null: false, foreign_key: true
      t.belongs_to :tree_category_question, null: false, foreign_key: true, index: { name: :index_sctq_on_tcqid }
      t.string :survey_monkey_page_id
      t.string :survey_monkey_id

      t.timestamps
    end

  end
end
