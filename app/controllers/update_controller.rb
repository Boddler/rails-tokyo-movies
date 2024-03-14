class UpdateController < ApplicationController
  include UpdateHelper

  def update
    titles = scrape(Cinema.all)
    api_results = first_api_call(titles)
    # Returns an array of arrays
    # movie info from TMDB, original scraped title & cinema instance
    unsaved_models = group_call(api_results)
    movies_create(unsaved_models)
    times = showings(Cinema.all.first)
    showing_create(times, Cinema.all.first)
    Showing.where("date < ?", Date.today).destroy_all
    Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    redirect_to root_path
  end
end
