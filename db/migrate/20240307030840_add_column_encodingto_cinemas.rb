class AddColumnEncodingtoCinemas < ActiveRecord::Migration[7.0]
  def change
    add_column :cinemas, :encoding, :string
  end
end
