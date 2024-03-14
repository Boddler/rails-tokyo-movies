class UpdateController < ApplicationController
  include UpdateHelper

  def update
    titles = scrape(Cinema.all)
    # Updated for 2+ cinemas to here
    # titles is a hash, keys are the cinema.name, value is an array of cleaned up titles
    api_results = first_api_call(titles)
    @titles = api_results
    unsaved_models = group_call(api_results)
    movies_create(unsaved_models)
    times = showings(Cinema.all.first)
    showing_create(times, Cinema.all.first)
    Showing.where("date < ?", Date.today).destroy_all
    Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    redirect_to root_path
  end
end
