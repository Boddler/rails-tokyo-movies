require "net/http"
require "json"
require "dotenv/load"
require "date"
require "nokogiri"
require "open-uri"
# require_relative "config/environment"?# require_relative "../cnm_meguro"
# require_relative "app/mailers/application_mailer"
# require_relative "app/mailers/movie_mailer"

api_key = ENV["TMDB_API_KEY"]

file = "shochiku.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "utf-8")

times_array = []

# doc.search(".top-schedule-area").each do |boxes|
#   # boxes.each do |box|
#   #   times_array << box.search(".schedule-item").text.strip
#   times_array << boxes
#   # end
# end

# times_array.each do |x|
#   puts x
# end

titles = []
times = []

# times_array.each do |box|
#   box.search(".schedule-item").each do |row|
#     titles << row.at("th").text.strip
#   end
# end

search_results = []

# Pull the top-schedule-area mbM elements
# Iterate through them and:
# add the first th element as the dates
# add the second th element inside that as the movie title
# add td elements inside as the times

doc.search(".top-schedule-area .schedule-item").each do |boxes|
  hash = {}
  date_text = boxes.search('th[colspan="4"]').text
  hash[:title] = boxes.css("th").text.strip
  hash[:date] = date_text
  hash[:times] = boxes.css("td").map(&:text)
  times_array << hash
end

times_array.each do |x|
  puts x
end
