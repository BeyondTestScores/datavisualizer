class CreateSurveys < ActiveRecord::Migration[6.0]
  def change
    create_table :surveys do |t|
      t.string :name
      t.belongs_to :tree
      t.string :survey_monkey_id
      t.integer :kind

      t.timestamps
    end
  end
end
