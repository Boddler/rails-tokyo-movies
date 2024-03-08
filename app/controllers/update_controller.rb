class UpdateController < ApplicationController
  include UpdateHelper

  def update
    titles = scrape(Cinema.all.first)
    api_results = first_api_call(titles)
    @titles = api_results
    group_call(api_results)
    Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    times = showings(Cinema.all.first)
    showing_create(times, Cinema.all.first)
    Showing.where("date < ?", Date.today).destroy_all
    redirect_to root_path
  end
end
