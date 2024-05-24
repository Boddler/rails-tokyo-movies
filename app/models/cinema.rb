class Cinema < ApplicationRecord
  extend FriendlyId
  has_many :showings, dependent: :destroy
  validates :name, presence: true
  validates :location, presence: true
  validates :url, presence: true
  has_many :movies, through: :showings
  friendly_id :name, use: :slugged

  def to_param
    slug
  end
end
