class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies do |t|
      t.string :name
      t.string :language
      t.integer :minutes
      t.text :description
      t.timestamps
    end
  end
end
