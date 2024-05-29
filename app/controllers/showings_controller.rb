class ShowingsController < ApplicationController
  include Pagy::Backend

  def index
    @cinemas = Cinema.all
    showings = Showing.joins(:movie).where(movies: { hide: false })
    @languages = Showing.joins(:movie).where(movies: { hide: false }).pluck("movies.language").uniq
    @showings = []
    cinemas = []
    movie_lang = []
    days = []
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
    end
    if params[:dates].present?
      date_pattern = /(\d{4}-\d{2}-\d{2})/
      matches = params[:dates].scan(date_pattern).flatten
      start_date = Date.strptime(matches[0], "%Y-%m-%d")
      end_date = Date.strptime(matches[1], "%Y-%m-%d") if matches[1]
      if end_date.nil?
        showings.each do |showing|
          days << showing if showing.date == start_date
        end
      else
        showings.each do |showing|
          days << showing if showing.date >= start_date && showing.date <= end_date
        end
      end
    end
    @showings = movie_lang if @showings.empty? && cinemas.empty?
    @showings = cinemas if @showings.empty? && movie_lang.empty?
    @showings &= movie_lang unless movie_lang.empty?
    @showings &= cinemas unless cinemas.empty?
    @showings = cinemas &= movie_lang if @showings.empty?
    @showings = days if @showings.empty?
    @showings &= days unless days.empty?
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
