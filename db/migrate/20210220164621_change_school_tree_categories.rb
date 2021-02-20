class ChangeSchoolTreeCategories < ActiveRecord::Migration[6.0]
  def change
    remove_column :school_tree_categories, :response_count
    remove_column :school_tree_categories, :answer_index_total
    remove_column :school_tree_categories, :zscore
    add_column :tree_categories, :nonlikert, :float
  end
end
