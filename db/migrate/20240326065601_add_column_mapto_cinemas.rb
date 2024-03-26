class AddColumnMaptoCinemas < ActiveRecord::Migration[7.0]
  def change
    add_column :cinemas, :map, :string
  end
end
