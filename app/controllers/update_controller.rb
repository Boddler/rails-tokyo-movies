class UpdateController < ApplicationController
  include UpdateHelper

  def update
    # Showing.where("date < ?", Date.today).destroy_all
    titles = scrape(Cinema.all.first)
    api_results = first_api_call(titles)
    @titles = api_results
    group_call(api_results)
    # Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    # raise
    # redirect_to root_path
  end
end
