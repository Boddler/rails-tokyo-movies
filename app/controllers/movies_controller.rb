class MoviesController < ApplicationController
  def index
    @movies = Movie.all
    @showings = Showing.all
    @cinemas = Cinema.all
  end

  def show
    @movie = Movie.find(params[:id])
    @showings = Showing.all.where(movie_id: @movie)
    @cinemas = @showings.map(&:cinema).uniq
  end
end
