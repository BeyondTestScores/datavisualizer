class CreateResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :responses do |t|
      t.references :survey
      t.references :school_tree_category_question
      t.string :survey_monkey_response_id
      t.string :survey_monkey_choice_id
      t.integer :option
    end
  end
end
