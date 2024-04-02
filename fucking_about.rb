require "open-uri"
require "json"
require "nokogiri"
require "net/http"
require "dotenv/load"

file = "htmlexcerpt.html"
file = "shimo.html"
html = Nokogiri::HTML.parse(File.open(file), nil, "utf-8")

def shimo_dates(string)
  dates = []
  month = string.split("/").first.to_i
  match_data = string.match(/\/(.+)$/)
  integers = []
  puts "Month: #{month}" if string == "4/20(土)～26(金) 11：35～(終14：08)"
  puts "Match Data: #{match_data}" if string == "4/20(土)～26(金) 11：35～(終14：08)"
  if match_data
    integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
  end
  puts "Integers: #{integers}" if string == "4/20(土)～26(金) 11：35～(終14：08)"

  integers.each_with_index do |day, index|
    month += 1 if day < integers[integers.index(day) - 1] && !index.zero?
    dates << Date.new(Date.today.year, month, day) unless day == 0
    month -= 1 if day < integers[integers.index(day) - 1] unless index.zero?
  end

  if string.include?("～") || string.include?("〜")
    if dates[1]
      date_range = (dates[0]..dates[1])
      dates = date_range.to_a
    end
  end
  puts "Dates: #{dates}" if string == "4/20(土)～26(金) 11：35～(終14：08)"
  dates
end

checking = []

html.search(".box").each do |element|
  unless element.search(".day").first.nil?
    if element.search(".day").first.text.strip.include?("\n")
      element.search(".day").first.text.strip.split("\n").each do |snippet|
        hash = {}
        hash[:date] = shimo_dates(snippet)
        hash[:title] = element.search(".eiga-title").first.text.strip unless element.search(".eiga-title").first.nil?
        hash[:times] = snippet.match(/\d{1,2}：\d{2}|\d{1,2}:\d{2}/)&.[](0)
        checking << hash
      end
    else
      title = element.search(".eiga-title").first.text.strip unless element.search(".eiga-title").first.nil?
      time = element.search(".day").first.text.strip.match(/\d{1,2}：\d{2}/)
      dates = shimo_dates(element.search(".day").first.text.strip) # unless element.search(".eiga-title").first.text.strip.nil?
      string = element.search(".day").first.text.strip # unless element.search(".eiga-title").first.text.strip.nil?
      dates.each do |build|
        new_hash = {}
        new_hash[:date] = build
        new_hash[:title] = title
        puts new_hash[:date] if new_hash[:title] == "VORTEX ヴォルテックス"
        puts dates if new_hash[:title] == "VORTEX ヴォルテックス"
        puts string if new_hash[:title] == "VORTEX ヴォルテックス"
        new_hash[:times] = time[0] if time
        checking << new_hash
      end
    end
  end
end

x = 110

pp checking.drop(x).take(10)

# Send the full date string to the dates method and return an array, then iterate over the dates.
