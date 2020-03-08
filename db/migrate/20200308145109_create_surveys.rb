class CreateSurveys < ActiveRecord::Migration[6.0]
  def change
    create_table :surveys do |t|
      t.string :name
      t.string :survey_monkey_id

      t.timestamps
    end

    create_table :survey_questions do |t|
      t.belongs_to :survey, null: false, foreign_key: true
      t.belongs_to :question, null: false, foreign_key: true

      t.timestamps
    end
  end
end
