class AddColumnHidetoMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :hide, :boolean, default: false
  end
end
