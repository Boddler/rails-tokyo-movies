# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Movie.destroy_all
Cinema.destroy_all
puts "Movies & Cinemas deleted"

require 'date'

movie_1 = Movie.new(
  name: "Fargo",
  language: "English",
  minutes: 120
)

movie_1.save

movie_2 = Movie.new(
  name: "Bait",
  language: "Welsh",
  minutes:  115
)

movie_2.save

cinema_1 = Cinema.new(
  name: "Meguro Cinema",
  location: "〒141-0021 東京都品川区上大崎２丁目２４−１５ 朝日建物株式会社 目黒西口ビル B1",
  url: "http://www.okura-movie.co.jp/meguro_cinema/now_showing.html",
  description: "A small, single screen cinema showing old and new movies."
)

cinema_1.save

cinema_2 = Cinema.new(
  name: "Kawasaki Art Centre",
  location: "〒215-0004 神奈川県川崎市麻生区万福寺６丁目７−１",
  url: "https://kac-cinema.jp/",
  description: "A cinema with many European movies."
)

cinema_2.save

20.times do
  movie = Movie.all.sample
  cinema = Cinema.all.sample
  date = rand(10.weeks).seconds.from_now

  showing = Showing.new(
    movie_id: movie.id,
    cinema_id: cinema.id,
    datetime: date
  )

  if showing.save
    puts "Showing created"
  else
    puts "Failed to create showing - Errors: #{showing.errors.full_messages.join(', ')}"
end
end
