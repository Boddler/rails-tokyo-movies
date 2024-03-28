class UpdateController < ApplicationController
  include UpdateHelper

  def update
    # cinemas = Cinema.all
    cinemas = [Cinema.last]
    titles = scrape(cinemas)
    api_results = first_api_call(titles)
    unsaved_models = group_call(api_results)
    movies_create(unsaved_models)
    @times = showings(cinemas)
    showing_create(@times)
    Showing.where("date < ?", Date.today).destroy_all
    # Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    redirect_to root_path
  end
end
