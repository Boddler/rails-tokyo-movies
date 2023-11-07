require "net/http"
require "json"
require "dotenv/load"
require "date"
# require 'open-uri'

# api_key = ENV["TMDB_API_KEY"]

require "nokogiri"

def date(date_string)
  if date_string.include?("〜")
    date_ranges = date_string.scan(/(\d{1,2})月(\d{1,2})日/)
    start_date = Date.new(Date.today.year, date_ranges[0][0].to_i, date_ranges[0][1].to_i)
    end_date = Date.new(Date.today.year, date_ranges[-1][0].to_i, date_ranges[-1][1].to_i)
    (start_date..end_date).map do |date|
      "#{date.month}月#{date.day}日(#{date.strftime("%a")})"
    end
  else
    date_ranges = date_string.scan(/(\d{1,2})月(\d{1,2})日/)
    return [] if date_ranges.empty?

    date_ranges.map do |matches|
      start_month = matches[0].to_i
      start_day = matches[1].to_i
      "#{start_month}月#{start_day}日(#{Date.new(Date.today.year, start_month, start_day).strftime("%a")})"
    end
  end
end

file = "meguro6.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "shift-JIS")
result = []

doc.search("#timetable").each do |line|
  dates = date(line.css("p").text)
  line.css(".time_box tr").each do |row|
    title = row.css(".time_title").text.strip
    times = row.css(".time_type2").map { |el| el.text.strip }
    times.each do |time|
      start_time = time.match(/(0?[0-9]|1[0-9]|2[0-3]):[0-5][0-9]/)
      if start_time && dates.size > 0
        dates.each do |date|
          matching_hash = result.find { |hash| hash[:name] == title && hash[:date].include?(date) }
          if matching_hash
            matching_hash[:times] ||= []
            matching_hash[:times] << start_time[0]
          else
            result << { name: title, times: [start_time[0]], date: date }
          end
        end
      end
    end
  end
end

# end

# result.each do |date|
#   movie = Movie.all.find(date[:name])
#   showing = Showing.new(date: date[:date], time: date[:times], movie_id: movie, cinema_id: Cinema.all.first)
#   showing.save
# end

# puts result.select { |movie| movie[:name] == "プリシラ" }
puts result.sort_by { |movie| movie[:name] }
# puts result
puts "There are #{result.size} entries"
puts Movie.all.first

# To change the dates to Date objects
# fixed_dates = date(dates)
# lengthened_dates = fixed_dates.map do |date_string|
#   Date.strptime(date_string, "%m月%d日(%a)")
# end

# result << { name: title, time: start_time[0], dates: lengthened_dates }
