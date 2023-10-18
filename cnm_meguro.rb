require "net/http"
require "json"
require "dotenv/load"
require "date"
# require 'open-uri'

# api_key = ENV["TMDB_API_KEY"]

require "nokogiri"

def date(date_string)
  return [] if date_string.nil? || date_string.empty?

  matches = date_string.scan(/(\d{1,2})月(\d{1,2})日/)

  return [] if matches.empty?

  start_month = matches[0][0].to_i
  start_day = matches[0][1].to_i

  if matches.size > 1
    end_month = matches[1][0].to_i
    end_day = matches[1][1].to_i

    date_range = (start_day..end_day).map do |day|
      "#{format("%02d", start_month)}月#{format("%02d", day)}日(#{Date.new(Date.today.year, start_month, day).strftime("%a")})"
    end
  else
    date_range = ["#{format("%02d", start_month)}月#{format("%02d", start_day)}日(#{Date.new(Date.today.year, start_month, start_day).strftime("%a")})"]
  end
  return date_range
end

file = "meguro5.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "shift-JIS")
result = []

doc.search("#timetable").each do |line|
  dates = line.css("p").text.strip
  fixed_dates = date(dates)
  lengthened_dates = fixed_dates.map do |date_string|
    Date.strptime(date_string, "%m月%d日(%a)")
  end
  line.css(".time_box tr").each do |row|
    title = row.css(".time_title").text.strip
    times = row.css(".time_type2").map { |el| el.text.strip }
    times.each do |time|
      start_time = time.match(/\d{2}:\d{2}/)

      if start_time && dates.size > 1
        result << { name: title, time: start_time[0], dates: lengthened_dates }
      end
    end
  end
end

puts result.select { |movie| movie[:name] == "ノッキン･オン･ヘブンズ･ドア" }
puts result
puts "There are #{result.size} entries"
