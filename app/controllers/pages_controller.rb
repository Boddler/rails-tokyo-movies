class PagesController < ApplicationController
  def home
    @movies = Movie.all.select { |movie| movie.hide == false }
    @showings = Showing.all
    @cinema = Cinema.all
  end

  def about
  end
end
