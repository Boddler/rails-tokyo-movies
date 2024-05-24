class Movie < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_many :showings, dependent: :destroy
  validates :name, presence: true
  has_many :cinemas, through: :showings
  validates :tmdb_id, uniqueness: true, unless: :special_case?

  def special_case?
    tmdb_id == -1 || tmdb_id.zero?
  end

  def to_param
    slug
  end

  include PgSearch::Model
  multisearchable against: [:name, :director]
end
