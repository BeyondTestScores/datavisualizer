class CreateQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.string :text
      t.string :option1
      t.string :option2
      t.string :option3
      t.string :option4
      t.string :option5
      t.belongs_to :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
