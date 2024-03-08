class AddColumnScheduletoCinemas < ActiveRecord::Migration[7.0]
  def change
    add_column :cinemas, :schedule, :string
  end
end
