require "net/http"

class MoviesController < ApplicationController
  include UpdateHelper

  def index
    @cinemas = Cinema.all
    @languages = Movie.all.map(&:language)
    @movies = []
    if params[:query].present?
      @movies = Movie.all.select { |movie| movie.hide == false }
      @movies = PgSearch.multisearch(params[:query]).map do |result|
        result.searchable_type.constantize.find(result.searchable_id)
      end
    end
    @movies = @movies.uniq
  end

  if params[:filter_cinema].present?
    @movies = @movies.joins(:cinemas).where(cinemas: { name: params[:filter_cinema] })
  end

  if params[:filter_language].present?
    @movies = @movies.where(language: params[:filter_language])
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
    new_movie_id = params[:movie].nil? ? -1 : params[:movie][:runtime].to_i
    if new_movie_id == -1
      blank_update(@movie)
    else
      hash = {}
      hash[:placeholder] = [@movie.web_title]
      results = [[[first_api_call(hash)[0][0][0].select { |element| element["id"] == new_movie_id }.first, @movie.web_title]]]
      results = [[api_call_by_id(new_movie_id), @movie.web_title]] if results[0][0][0].nil?
      movie_hash = group_call(results)[0]
      movie_hash.delete(:id)
      movie_hash[:web_title] = @movie.web_title
      if @movie.update(movie_hash)
        redirect_to @movie, notice: "Movie was successfully updated."
      else
        render :edit
      end
    end
  end

  def toggle_hide
    @movie = Movie.find(params[:id])
    @movie.update(hide: !@movie.hide)
    redirect_to @movie
  end

  private

  def temp_movies(list)
    results = []
    list[0].each do |movie|
      temp_movie = Movie.new(name: movie["title"], description: movie["overview"],
                             year: movie["release_date"], language: movie["language"],
                             poster: "https://image.tmdb.org/t/p/w500/#{movie["poster_path"]}",
                             runtime: movie["id"].to_i)
      results << temp_movie
      #  Note - TMDB id is being saved as the runtime
    end
    results
  end
end
