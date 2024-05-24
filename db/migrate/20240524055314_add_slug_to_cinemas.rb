class AddSlugToCinemas < ActiveRecord::Migration[7.0]
  def change
    add_column :cinemas, :slug, :string
    add_index :cinemas, :slug, unique: true
  end
end
