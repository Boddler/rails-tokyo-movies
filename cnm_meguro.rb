require "net/http"
require "json"
require "dotenv/load"
require "date"
# require 'open-uri'

# api_key = ENV["TMDB_API_KEY"]

require "nokogiri"

require "date"

def date(date_string)
  return [] if date_string.nil? || date_string.empty?

  date_ranges = date_string.scan(/(\d{1,2})月(\d{1,2})日/)

  return [] if date_ranges.empty?

  date_ranges.flat_map do |matches|
    start_month = matches[0].to_i
    start_day = matches[1].to_i

    (start_day..start_day).map do |day|
      "#{format("%02d", start_month)}月#{format("%02d", day)}日(#{Date.new(Date.today.year, start_month, day).strftime("%a")})"
    end
  end
end

file = "meguro6.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "shift-JIS")
result = []

doc.search("#timetable").each do |line|
  dates = line.css("p").text.strip
  line.css(".time_box tr").each do |row|
    title = row.css(".time_title").text.strip
    times = row.css(".time_type2").map { |el| el.text.strip }
    times.each do |time|
      start_time = time.match(/(0?[0-9]|1[0-9]|2[0-3]):[0-5][0-9]/)
      if start_time && dates.size > 1
        # result << { name: title, time: start_time[0], dates: 1 }
        result << { name: title, time: start_time[0], dates: date(dates) }
      end
    end
  end
end

# puts result.select { |movie| movie[:name] == "プリシラ" }
puts result.sort_by { |movie| movie[:name] }
puts "There are #{result.size} entries"

# To change the dates to Date objects
# fixed_dates = date(dates)
# lengthened_dates = fixed_dates.map do |date_string|
#   Date.strptime(date_string, "%m月%d日(%a)")
# end

# result << { name: title, time: start_time[0], dates: lengthened_dates }
