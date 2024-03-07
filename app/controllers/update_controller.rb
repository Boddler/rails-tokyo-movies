class UpdateController < ApplicationController
  include UpdateHelper

  def update
    # Showing.where("date < ?", Date.today).destroy_all
    titles = scrape(Cinema.all.first)
    api_results = first_api_call(titles)
    # api_results = api_results.sort_by { |movie| -movie[0]["vote_count"].to_f }
    @titles = api_results
    group_call(api_results)
    # Movie.includes(:showings).where(showings: { id: nil }).destroy_all
    # raise
    # redirect_to root_path
  end
end
