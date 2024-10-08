require "net/http"

class MoviesController < ApplicationController
  include UpdateHelper
  include Pagy::Backend
  before_action :authenticate, only: [:edit, :update, :toggle_hide]

  def index
    @cinemas = Cinema.all
    @directors = []
    @films = Movie.all.select { |movie| movie.hide == false }
    Movie.all.each { |movie| @directors << movie.director }
    @directors.uniq!
    movies = @films
    today = Date.today
    movies = movies.reject do |movie|
      movie.showings.all? { |showing| showing.date < today }
    end
    @languages = movies.map(&:language)
    @movies = []
    cinemas = []
    movie_lang = []
    if params[:query].present?
      @movies = PgSearch.multisearch(params[:query]).map do |result|
        result.searchable_type.constantize.find(result.searchable_id)
      end
    end
    if params[:cinemas].present?
      params[:cinemas].each do |cinema|
        next if cinema == ""

        movies.each do |movie|
          cinemas << movie if movie.showings.any? { |showing| showing.cinema_id == Cinema.find_by(name: cinema).id }
        end
      end
    end
    if params[:languages].present?
      params[:languages].each do |language|
        next if language == ""

        movies.each do |movie|
          movie_lang << movie if movie.language == language
        end
      end
    end
    @movies = movie_lang if @movies.empty? && cinemas.empty?
    @movies = cinemas if @movies.empty? && movie_lang.empty?
    @movies &= movie_lang unless movie_lang.empty?
    @movies &= cinemas unless cinemas.empty?
    @movies = cinemas &= movie_lang if @movies.empty?
    @movies = @movies.uniq
    @pagy, @movies = pagy(Movie.where(id: @movies.map(&:id)), items: 30)
  end

  def show
    @movie = Movie.friendly.find(params[:id])
  end

  def edit
    @movie = Movie.friendly.find(params[:id])
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
      movie_hash[:tmdb_id] = movie_hash[:id]
      movie_hash.delete(:id)
      movie_hash[:slug] = movie_hash[:name]
      movie_hash[:web_title] = @movie.web_title
      if @movie.update(movie_hash)
        redirect_to @movie, notice: "Movie info successfully updated."
      else
        render :edit
      end
    end
  end

  def toggle_hide
    @movie = Movie.friendly.find(params[:id])
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

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["USERNAME"] && password == ENV["PASSWORD"]
    end
  end
end
