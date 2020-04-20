class AddAdministrativeMeasureToCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :administrative_measure, :boolean, null: false, default: false
  end
end
