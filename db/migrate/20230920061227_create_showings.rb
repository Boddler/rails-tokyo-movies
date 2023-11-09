class CreateShowings < ActiveRecord::Migration[7.0]
  def change
    create_table :showings do |t|
      t.references :movie, foreign_key: true
      t.references :cinema, foreign_key: true
      t.date :date
      t.string :times, array: true, default: []
      t.timestamps
    end
  end
end
