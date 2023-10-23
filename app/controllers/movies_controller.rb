class MoviesController < ApplicationController
  def index
    @movies = Movie.all
    @showings = Showing.all
    @cinema = Cinema.all
  end

  def show
    @movie = Movie.find(params[:id])
    @showings = Showing.all.where(movie_id: @movie)
  end
end
