class AddSlugToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :slug, :string
    add_index :schools, :slug, unique: true
  end
end
