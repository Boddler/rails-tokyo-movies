class PagesController < ApplicationController
  def home
    @movies = Movie.all
    @showings = Showing.all
    @cinema = Cinema.all
  end

  def about
  end
end
