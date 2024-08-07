class AdditionsController < ApplicationController
  def index
    @latest_additions = Movie.where("created_at >= ?", 1.hour.ago).order(created_at: :desc)
    # @recent_additions = Movie.where("created_at.day >= ?", (Movie.last.created_at.day))
    @recent_additions = Movie.where("created_at >= ?", Movie.maximum(:created_at).beginning_of_day)
  end
end
