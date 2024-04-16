class UpdateController < ApplicationController
  include UpdateHelper

  def update
    cinemas = Cinema.all
    # cinemas = [Cinema.find_by_name("Waseda Shochiku")]
    titles = scrape(cinemas)
    api_results = first_api_call(titles)
    unsaved_models = group_call(api_results[0])
    movies_create(unsaved_models)
    unfound_movies(api_results[1])
    @times = showings(cinemas)
    showing_create(@times)
    Showing.where("date < ?", Date.today).destroy_all
    Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    redirect_to root_path
  end
end
