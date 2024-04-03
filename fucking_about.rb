require "open-uri"
require "json"
require "nokogiri"
require "net/http"
require "dotenv/load"

# file = "htmlexcerpt.html"
file = "shimo.html"
html = Nokogiri::HTML.parse(File.open(file), nil, "utf-8")

def date_handling(month, date1, date2 = nil)
  dates = []
  if date2.nil?
    dates << Date.new(Date.today.year, month, date1) unless date1.zero?
  else
    month += 1 if day < integers[integers.index(day) - 1] && !index.zero?
    dates << Date.new(Date.today.year, month, day) unless day.zero?
    month -= 1 if day < integers[integers.index(day) - 1] && !index.zero?
  end
  dates
end

def shimo_dates(string)
  dates = []
  p month = string.split("/").first.to_i
  p match_data = string.match(/\/(.+)$/)
  p match_data2 = string.match(/～(\d+)\(/) unless string.match(/～(\d+)\(/).nil?
  integers = []
  if match_data
    integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
  end
  p integers
  integers.each_with_index do |day, index|
    month += 1 if day < integers[integers.index(day) - 1] && !index.zero?
    dates << Date.new(Date.today.year, month, day) unless day.zero?
    month -= 1 if day < integers[integers.index(day) - 1] && !index.zero?
  end
  if string.include?("～") || string.include?("〜")
    if dates[1]
      date_range = (dates[0]..dates[1])
    else
      if match_data2
        day2 = match_data2[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
      end
      date_range = (dates[0]..integers[0])
      p day2
    end
    dates = date_range.to_a
  end
  dates
end

def clean_titles(list)
  list.map! do |str|
    str.sub(/4K.*/, "")
      .sub(/デジタルリマスター.*/, "")
      .sub(/＋.*/, "")
      .sub(/　.*/, "")
      .sub(/★.*/, " ")
      .sub(/\n/, "")
      .sub(/【ﾚｲﾄｼｮｰ】/, "")
      .sub(/【ﾓｰﾆﾝｸﾞｼｮｰ】/, "")
      .sub(/【劇場版】.*/, "")
      .sub(/劇場公開版.*/, "")
      .gsub(/\t.*/, "")
      .sub(/【吹替版】/, "")
      .sub(/ ４Kレストア.*/, "")
      .strip
  end
end

checking = []

# html.search(".box").each do |element|
#   # unless element.search(".day").first.nil?
#   if element.search(".day").first.text.strip.include?("\n")
#     element.search(".day").first.text.strip.split("\n").each do |snippet|
#       hash = {}
#       hash[:date] = shimo_dates(snippet)
#       hash[:title] = element.search(".eiga-title").first.text.strip unless element.search(".eiga-title").first.nil?
#       hash[:times] = snippet.match(/\d{1,2}：\d{2}|\d{1,2}:\d{2}/)&.[](0)
#       checking << hash
#     end
#   else
#     title = element.search(".eiga-title").first.text.strip unless element.search(".eiga-title").first.nil?
#     time = element.search(".day").first.text.strip.match(/\d{1,2}：\d{2}/)
#     dates = shimo_dates(element.search(".day").first.text.strip) # unless element.search(".eiga-title").first.text.strip.nil?
#     string = element.search(".day").first.text.strip # unless element.search(".eiga-title").first.text.strip.nil?
#     dates.each do |build|
#       new_hash = {}
#       new_hash[:date] = build
#       new_hash[:title] = title
#       puts new_hash[:date] if new_hash[:title] == "VORTEX ヴォルテックス"
#       puts dates if new_hash[:title] == "VORTEX ヴォルテックス"
#       puts string if new_hash[:title] == "VORTEX ヴォルテックス"
#       new_hash[:times] = time[0] if time
#       checking << new_hash
#     end
#     # end
#   end
# end

html.search(".box").each do |box|
  hash = {}
  title = box.search(".eiga-title").first.text.strip unless box.search(".eiga-title").first.nil?
  hash[:title] = clean_titles([title])[0] if title
  p hash[:title]
  time = box.search(".day").first.text.strip.match(/\d{1,2}：\d{2}|\d{1,2}:\d{2}/)&.[](0)
  hash[:times] = time.gsub("：", ":") if hash[:title]
  date_cell = box.search(".day").first.text.strip
  dates = shimo_dates(date_cell) if date_cell
  hash[:dates] = dates
  checking << hash if hash[:title]
end

# x = 110
# pp checking.drop(x).take(10)

# pp checking
pp checking.size

# Send the full date string to the dates method and return an array, then iterate over the dates.
