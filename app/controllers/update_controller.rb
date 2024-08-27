class UpdateController < ApplicationController
  include UpdateHelper
  before_action :authenticate

  def update
    # cinemas = Cinema.all
    movies = Movie.all
    cinemas = [Cinema.find_by_name("Kichijoji Up Link")]
    titles = scrape(cinemas)
    api_results = first_api_call(titles)
    pp api_results[1]
    second_pass = second_api_call(api_results[1])
    api_results[0] += second_pass[0]
    third_pass = third_api_call(second_pass[1])
    api_results[0] += third_pass[0]
    unsaved_models = group_call(api_results[0])
    movies_create(unsaved_models, movies)
    movies = Movie.all
    unfound_movies(third_pass[1], movies)
    movies = Movie.all
    times = showings(cinemas)
    showing_create(times, movies)
    Showing.where("date < ?", Date.today).destroy_all
    Showing.where(times: []).destroy_all
    Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    redirect_to latest_path
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["USERNAME"] && password == ENV["PASSWORD"]
    end
  end
end
