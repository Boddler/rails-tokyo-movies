class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies do |t|
      t.string :name
      t.string :web_title, uniqueness: true
      t.string :language
      t.integer :runtime
      t.text :description
      t.string :director
      t.string :poster
      t.string :background
      t.integer :year
      t.float :popularity
      t.string :cast, array: true, default: []
      t.timestamps
    end
  end
end
