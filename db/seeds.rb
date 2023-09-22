# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'dotenv/load'
api_key = ENV['TMDB_API_KEY']

require "nokogiri"
# require "open-uri"
file = "meguro.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "shift-JIS")

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


# def scrape(keyword)
#   attr_reader :search_results

# html_content = file
# doc = Nokogiri::HTML.parse(html_content)
@search_results = []
doc.search('.time_title').each do |element|
  @search_results << element.text.strip
#  @search_results[element.text.strip.split.first(6).join(" ")] = false
end


require 'net/http'
require 'json'

japanese_title = 'ノスフェラトゥ'

# Encode the Japanese title for URL
encoded_title = URI.encode_www_form_component(japanese_title)

url = URI("https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{encoded_title}&language=en-gb")

response = Net::HTTP.get(url)
movie_data = JSON.parse(response)

if movie_data['results'].any?
  title = movie_data['results'][0]['title']
  original_title = movie_data['results'][0]['original_title']
  overview = movie_data['results'][0]['overview']
  release_date = movie_data['results'][0]['release_date']
  director = movie_data['results'][0]['director']

  puts "Title: #{title}"
  puts "Original Title: #{original_title}"
  puts "Overview: #{overview}"
  puts "Release Date: #{release_date}"
  puts "Directed by: #{director}"
else
  puts "Movie not found"
end

puts response
