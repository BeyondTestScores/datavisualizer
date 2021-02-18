class AddOptionsToSchoolTreeCategoryQuestions < ActiveRecord::Migration[6.0]
  def change
    add_column :school_tree_category_questions, :survey_monkey_option1_id, :string
    add_column :school_tree_category_questions, :survey_monkey_option2_id, :string
    add_column :school_tree_category_questions, :survey_monkey_option3_id, :string
    add_column :school_tree_category_questions, :survey_monkey_option4_id, :string
    add_column :school_tree_category_questions, :survey_monkey_option5_id, :string
  end
end
