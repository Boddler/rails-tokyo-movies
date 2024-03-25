# # require "net/http"
require "json"
# # require "dotenv/load"
require "date"
require "nokogiri"
require "open-uri"
# # require_relative "config/environment"?# require_relative "../cnm_meguro"
# # require_relative "app/mailers/application_mailer"
# # require_relative "app/mailers/movie_mailer"

api_key = ENV["TMDB_API_KEY"]

file = "shochiku.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "utf-8")

# times_array = []

# def dates(string)
#   dates = []
#   month = string.split("/").first.to_i
#   match_data = string.match(/\/(.+)$/)
#   if match_data
#     integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
#   end
#   integers.each_with_index do |day, index|
#     month += 1 if day < integers[integers.index(day) - 1] && !index.zero?
#     dates << Date.new(Date.today.year, month, day) unless day == 0
#     month -= 1 if day < integers[integers.index(day) - 1] unless index.zero?
#   end
#   dates
# end

# doc.search(".top-schedule-area").each do |table|
#   date_text = table.search('th[colspan="4"]').text
#   # dates = dates(date_text)
#   heads = table.search(".schedule-item")
#   heads.each do |row|
#     hash = {}
#     hash[:date] = dates(date_text)
#     hash[:name] = row.at("th").text.strip
#     hash[:times] = row.css("td").map(&:text).reject { |string| string == "" }.map! { |time| time.sub(/～.*/, "") }
#     times_array << hash if hash[:name]
#   end
# end

# # pp times_array[7].split("･")
# # pp times_array[7].split("/").first
# # pp times_array[7].split("/")[-2].split("")[-1]
# # # pp times_array[7].split("/")

# times_array.each do |hash|
#   # pp hash[:name]
#   # pp hash[:times]
#   pp hash[:date]
#   puts "*" * 30
# end

# # def date_parse(hash)
# #   month_1 = hash[:date].split("/").first
# #   month_2 = hash[:date].split("/")[-2].split("")[-1]
# #   pp month_1
# #   pp month_2 + " 2nd" unless month_1 == month_2
# # end

# # final = []

# # times_array.each do |date|
# #   puts date[:date]
# #   final << parse_dates(date[:date])
# # end

# # # final.each do |x|
# # #   puts x[0]
# # # end

# # date_string = ("3/19(火)･20(水･祝)･21(木)")

# # month = date_string.split("/").first.to_i
# # days = date_string.split("/")

# # pp month

# # string = "3/19･20･4/21"
# # # Extract the part after the first "/"
# # match_data = string.match(/\/(.+)$/)
# # if match_data
# #   # Split the extracted part by "･" to get individual elements
# #   integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
# #   puts integers.inspect
# # end

def sho_dates(string)
  dates = []
  month = string.split("/").first.to_i
  match_data = string.match(/\/(.+)$/)
  integers = []

  if match_data
    integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
  end

  integers.each_with_index do |day, index|
    month += 1 if day < integers[integers.index(day) - 1] && !index.zero?
    dates << Date.new(Date.today.year, month, day) unless day == 0
    month -= 1 if day < integers[integers.index(day) - 1] unless index.zero?
  end

  if string.include?("～")
    date_range = (dates[0]..dates[1])
    dates = date_range.to_a
  end

  dates
end

def shochiku_showings(doc)
  result = []
  doc.search(".top-schedule-area").each do |table|
    date_text = table.search('th[colspan="4"]').text
    dates = sho_dates(date_text)
    heads = table.search(".schedule-item")
    heads.each do |row|
      hash = {}
      dates.each do |date|
        hash[:date] = date
        hash[:name] = row.at("th").text.strip
        hash[:times] = row.css("td").map(&:text).reject { |string| string == "" }.map! { |time| time.sub(/～.*/, "") }
        result << hash if hash[:name]
      end
    end
  end
  pp result
end

results = shochiku_showings(doc)

x = 0

# p results.class
# puts "*" * 30
# p results[x]
# puts "*" * 30
# p results[x + 1]
# puts "*" * 30
# p results[x + 2]
# puts "*" * 30
# p results[x + 3]
# puts "*" * 30
# p results[x + 4]
