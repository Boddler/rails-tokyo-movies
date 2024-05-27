class ShowingsController < ApplicationController
  include Pagy::Backend

  def index
    @cinemas = Cinema.all
    showings = Showing.joins(:movie).where(movies: { hide: false })
    @languages = Showing.joins(:movie).where(movies: { hide: false }).pluck("movies.language").uniq
    @showings = []
    cinemas = []
    movie_lang = []
    if params[:cinemas].present?
      params[:cinemas].each do |cinema_name|
        next if cinema_name.blank?

        cinema = Cinema.find_by(name: cinema_name)
        next unless cinema

        showings.each do |showing|
          cinemas << showing if showing.cinema_id == cinema.id
        end
      end
    end
    if params[:languages].present?
      params[:languages].each do |language|
        next if language.blank?

        showings.each do |showing|
          movie_lang << showing if showing.movie.language == language
        end
      end
      raise
    end
    @showings = movie_lang if @showings.empty? && cinemas.empty?
    @showings = cinemas if @showings.empty? && movie_lang.empty?
    @showings &= movie_lang unless movie_lang.empty?
    @showings &= cinemas unless cinemas.empty?
    @showings = cinemas &= movie_lang if @showings.empty?
    @showings = @showings.uniq
    # @pagy, @showings = pagy(Showing.where(id: @showings.map(&:id)).order(:date, :times), items: 30)
    @pagy, @showings = pagy(
      Showing
        .where(id: @showings.map(&:id))
        .where("date >= ?", Date.today)
        .order(:date, :times),
      items: 30,
    )
  end
end
