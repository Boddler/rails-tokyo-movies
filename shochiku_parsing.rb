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

doc.search(".top-schedule-area").each do |table|
  date_text = table.search('th[colspan="4"]').text
  heads = table.search(".schedule-item")
  heads.each do |row|
    hash = {}
    hash[:date] = date_text
    hash[:title] = row.at("th").text.strip
    hash[:times] = row.css("td").map(&:text).reject { |string| string == "" }.map! { |time| time.sub(/～.*/, "") }
    times_array << hash if hash[:title]
  end
end

# pp times_array[7].split("･")
# pp times_array[7].split("/").first
# pp times_array[7].split("/")[-2].split("")[-1]
# # pp times_array[7].split("/")

# times_array.each do |hash|
#   pp hash[:title]
#   pp hash[:times]
#   pp hash[:date]
#   puts "*" * 30
# end

def date_parse(hash)
  month_1 = hash[:date].split("/").first
  month_2 = hash[:date].split("/")[-2].split("")[-1]
  pp month_1
  pp month_2 + " 2nd" unless month_1 == month_2
end

final = []

# times_array.each do |date|
#   puts date[:date]
#   final << parse_dates(date[:date])
# end

# final.each do |x|
#   puts x[0]
# end

date_string = ("3/19(火)･20(水･祝)･21(木)")

month = date_string.split("/").first.to_i
days = date_string.split("/")

pp month

string = "3/19･20･4/21"
# Extract the part after the first "/"
match_data = string.match(/\/(.+)$/)
if match_data
  # Split the extracted part by "･" to get individual elements
  integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
  puts integers.inspect
end
