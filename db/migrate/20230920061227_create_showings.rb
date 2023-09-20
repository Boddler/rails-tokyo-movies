class CreateShowings < ActiveRecord::Migration[7.0]
  def change
    create_table :showings do |t|
      t.references :movie, foreign_key: true
      t.references :cinema, foreign_key: true
      t.datetime :datetime
      t.timestamps
    end
  end
end
