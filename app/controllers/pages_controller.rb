class PagesController < ApplicationController
  def home
    @movies = Movie.all
    @showings = Showing.all
    @cinema = Cinema.all
    # @movie = Movie.new
  end
end
