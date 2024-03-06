class UpdateController < ApplicationController
  include UpdateHelper

  def update
    # Showing.where("date < ?", Date.today).destroy_all
    Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    redirect_to root_path
  end
end
