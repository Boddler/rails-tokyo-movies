class UpdateController < ApplicationController
  include UpdateHelper

  def update
    cinemas = Cinema.all
    titles = scrape(cinemas)
    api_results = first_api_call(titles)
    unsaved_models = group_call(api_results)
    # Up to here
    # returns an array of instances to save
    # Has broken the edit path - fixing first then will come back to this
    movies_create(unsaved_models)
    times = showings(cinemas[0])
    showing_create(times, Cinema.all.first)
    Showing.where("date < ?", Date.today).destroy_all
    Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    redirect_to root_path
  end
end
