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
    hash = {}
    hash[:placeholder] = [@movie.web_title]
    @options = first_api_call(hash)[0][0]
    @temps = temp_movies(@options).reject { |movie| movie.description == @movie.description }.sort_by { |movie| -movie["vote_count"].to_f }
  end

  def update
    @movie = Movie.find(params[:id])
    new_movie_id = params[:movie][:runtime].to_i
    hash = {}
    hash[:placeholder] = [@movie.web_title]
    results = [[[first_api_call(hash)[0][0].select { |element| element["id"] == new_movie_id }.first, @movie.web_title]]]
    if results[0][0][0].nil?
      results = [[api_call_by_id(new_movie_id), @movie.web_title]]
    end

    movie_hash = group_call(results)[0]
    movie_hash.delete(:id)
    movie_hash[:web_title] = @movie.web_title
    movie_hash[:poster] = "https://image.tmdb.org/t/p/w185/#{movie_hash[:poster]}"
    # raise
    if @movie.update(movie_hash)
      redirect_to @movie, notice: "Movie was successfully updated."
    else
      render :edit
    end
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
