class Cinema < ApplicationRecord
  has_many :showings, dependent: :destroy
  validates :name, presence: true
  validates :location, presence: true
  validates :url, presence: true
  has_many :movies, through: :showings
end
