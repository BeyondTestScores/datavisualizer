class CreateSchoolCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :school_categories do |t|
      t.belongs_to :category, null: false, foreign_key: true
      t.belongs_to :school, null: false, foreign_key: true
      t.integer :response_count
      t.integer :answer_index_total
      t.float :zscore
      t.float :nonlikert
      t.string :year

      t.timestamps
    end
  end
end
