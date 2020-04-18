class AddNonLikertToCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :nonlikert, :float
  end
end
