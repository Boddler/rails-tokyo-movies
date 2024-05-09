class ChangeWebTitleToStringArray < ActiveRecord::Migration[7.0]
  def up
    change_column :movies, :web_title, :string, array: true, default: [], using: "ARRAY[web_title]"
  end

  def down
    change_column :movies, :web_title, :string
  end
end
