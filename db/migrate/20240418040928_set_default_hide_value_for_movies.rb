class SetDefaultHideValueForMovies < ActiveRecord::Migration[7.0]
  def up
    change_column_default :movies, :hide, false
    Movie.where(hide: nil).update_all(hide: false)
  end

  def down
    change_column_default :movies, :hide, nil
  end
end
