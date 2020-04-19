class AddAdministrativeMeasureToCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :administrative_measure, :boolean, default: false
  end
end
