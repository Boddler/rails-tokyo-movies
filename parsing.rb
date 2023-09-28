require "net/http"
require "json"
require "dotenv/load"
require "date"

api_key = ENV["TMDB_API_KEY"]

require "nokogiri"
# require 'open-uri'

file = "meguro2.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "shift-JIS")
result = []
timetable = doc.css("#timetable")

@movie_times = []
doc.search("#timetable").each do |row|
  # date << element unless element.text.strip.empty?
  dates = row.css("p").text.strip
  timetable.css(".time_box tr").each do |row|
    title = row.css(".time_title").text.strip
    times = row.css(".time_type2").map { |el| el.text.strip }
    # .text.strip unless element.text.strip.empty?

    times.each do |time|
      start_time = time.match(/\d{2}:\d{2}/)

      if start_time
        result << { name: title, time: start_time[0], start_date: dates }
      end
    end
  end
end

puts "There are #{result.size} entries"
puts result
# @movie_times.each do |row|
#   p row.css("p").text.strip
# end
