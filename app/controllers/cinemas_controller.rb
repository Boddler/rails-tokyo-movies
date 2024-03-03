class CinemasController < ApplicationController
  def index
    @cinemas = Cinema.all
  end

  def show
    @cinema = Cinema.find(params[:id])
    # @showings = Showing.all.where(cinema_id: @cinema)
    # @movies = @showings.map(&:movie).uniq
  end
end
