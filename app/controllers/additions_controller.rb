class AdditionsController < ApplicationController
  def index
    @latest_additions = Movie.where("created_at >= ?", 1.hour.ago).order(created_at: :desc)
    @recent_additions = Movie.order(created_at: :desc).limit(15)
  end
end
