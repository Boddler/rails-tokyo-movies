class Movie < ApplicationRecord
  has_many :showings, dependent: :destroy
  validates :name, presence: true
  has_many :cinemas, through: :showings

  # include PgSearch::Model
  # multisearchable against: [:name, :director]
end
