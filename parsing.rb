require "net/http"
require "json"
require "dotenv/load"
require "date"

api_key = ENV["TMDB_API_KEY"]

require "nokogiri"
# require 'open-uri'

file = "meguro.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "shift-JIS")
# puts doc
@search_results = []
doc.search(".jp_small2").each do |element|
  @search_results << element.text.strip
end

p @search_results
# p doc
