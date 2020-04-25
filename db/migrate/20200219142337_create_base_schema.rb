class CreateBaseSchema < ActiveRecord::Migration[6.0]
  def change

    create_table :categories do |t|
      t.string :name
      t.string :blurb
      t.text :description
      t.boolean :administrative_measure, null: false, default: false

      t.timestamps
    end

    create_table :questions do |t|
      t.string :text
      t.string :option1
      t.string :option2
      t.string :option3
      t.string :option4
      t.string :option5
      t.integer :kind

      t.timestamps
    end

    create_table :trees do |t|
      t.string :name

      t.timestamps
    end

    create_table :tree_categories do |t|
      t.belongs_to :tree, null: false, foreign_key: true
      t.belongs_to :category, null: false, foreign_key: true
      t.integer :parent_tree_category_id, foreign_key: true

      t.timestamps
    end

    create_table :tree_category_questions do |t|
      t.belongs_to :tree_category, null: false, foreign_key: true
      t.belongs_to :question, null: false, foreign_key: true

      t.timestamps
    end
  end
end
