class Showing < ApplicationRecord
  belongs_to :cinema
  belongs_to :movie
  # validates :datetime, presence: true
end
