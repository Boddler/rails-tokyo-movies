require "net/http"
require "json"
require "dotenv/load"
require "date"

api_key = ENV["TMDB_API_KEY"]

require "nokogiri"
# require 'open-uri'

file = "meguro2.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "shift-JIS")
# puts doc
@search_results = []
doc.search("#timetable").each do |element|
  @search_results << element.text.strip
end

# @search_results.each { |x| puts x}
puts @search_results[1]
# p doc
