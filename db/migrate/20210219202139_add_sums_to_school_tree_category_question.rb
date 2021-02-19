class AddSumsToSchoolTreeCategoryQuestion < ActiveRecord::Migration[6.0]
  def change
    add_column :school_tree_category_questions, :responses_sum, :integer, default: 0
    add_column :school_tree_category_questions, :responses_count, :integer, default: 0
    add_column :school_tree_categories, :responses_sum, :integer, default: 0
    add_column :school_tree_categories, :responses_count, :integer, default: 0
  end
end
