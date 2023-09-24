class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies do |t|
      t.string :name
      t.string :web_title
      t.string :language
      t.integer :runtime
      t.text :description
      t.string :director
      t.string :poster
      t.timestamps
    end
  end
end
