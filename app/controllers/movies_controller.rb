require "net/http"

class MoviesController < ApplicationController
  include UpdateHelper

  def index
    @movies = Movie.all
  end

  def show
    @movie = Movie.find(params[:id])
  end

  def edit
    @movie = Movie.find(params[:id])
    options = first_api_call([@movie.web_title])[0][0]
    @temps = temp_movies(options).reject! { |movie| movie.description == @movie.description }
    raise
  end

  private

  def temp_movies(list)
    results = []
    list.each do |movie|
      temp_movie = Movie.new(name: movie["title"], description: movie["overview"],
                             year: movie["release_date"], language: movie["language"],
                             poster: "https://image.tmdb.org/t/p/w185/#{movie["poster_path"]}",
                             runtime: movie["id"].to_i)
      results << temp_movie
      #  Note - TMDB id is being saved as the runtime
    end
    results
  end
end
