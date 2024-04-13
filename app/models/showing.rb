class Showing < ApplicationRecord
  validate :unique_attributes
  belongs_to :cinema
  belongs_to :movie

  def unique_attributes
    existing_record = Showing.where(cinema_id: self.cinema_id, movie_id: self.movie_id, date: self.date, times: self.times).first
    if existing_record && existing_record.id != self.id
      errors.add(:base, "Another record with the same attributes exists")
    end
  end
end
