require "open-uri"
require "json"
require "nokogiri"
require "net/http"
require "dotenv/load"

# file = "htmlexcerpt.html"
file = "shimo.html"
html = Nokogiri::HTML.parse(File.open(file), nil, "utf-8")

# def shimo_dates(string, month)
#   dates = []
#   match_data = string.match(/\/(.+)$/)
#   integers = []
#   # if match_data
#   #   integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
#   # end
#   if integers.empty?
#     integers = string.scan(/(\d+)\([^)]+\)/).flatten.map(&:to_i)
#   end
#   # p string
#   # p integers
#   # p "*" * 40

#   integers.each_with_index do |day, index|
#     month += 1 if day < integers[integers.index(day) - 1] && !index.zero?
#     dates << Date.new(Date.today.year, month, day) unless day.zero?
#     month -= 1 if day < integers[integers.index(day) - 1] && !index.zero?
#   end
#   if string.include?("～") || string.include?("〜")
#     if integers[1]
#       date_range = (dates[0]..dates[1])
#       dates = date_range.to_a
#     else
#       "To do...."
#     end
#   end
#   dates
# end

def shimo_dates(string, month)
  dates = []
  integers = string.scan(/(\d+)\([^)]+\)/).flatten.map(&:to_i)

  integers.each_with_index do |day, index|
    month += 1 if day < integers[index - 1] && index.positive?
    dates << Date.new(Date.today.year, month, day) unless day.zero?
    month -= 1 if day < integers[index - 1] && index.positive?
  end

  if string.include?("～") || string.include?("〜")
    dates = (dates.first..dates.last).to_a if dates.size > 1
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
final_array = []

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
  clean_title = clean_titles([title])[0] if title
  date_cell = box.search(".day").first.text.strip.gsub("～(", " (")
  if date_cell.include?("\n")
    date_cell.split("\n").each do |day|
      time = day.match(/\d{1,2}：\d{2}|\d{1,2}:\d{2}/)&.[](0)
      day.split("、").each_with_index do |part, index|
        month = day.split("/").first.to_i
        new_hash = {}
        new_hash[:title] = clean_title
        new_hash[:dates] = shimo_dates(part, month)
        new_hash[:times] = time.gsub("：", ":")
        checking << new_hash
      end
    end
  else
    time = box.search(".day").first.text.strip.match(/\d{1,2}：\d{2}|\d{1,2}:\d{2}/)&.[](0)
    new_time = time.gsub("：", ":") unless time.nil?
    date_cell.split("、").each_with_index do |part, index|
      month = date_cell.split("/").first.to_i
      hash = {}
      hash[:title] = clean_title
      hash[:dates] = shimo_dates(part, month) if date_cell && hash[:title]
      hash[:times] = new_time
      checking << hash if hash[:title]
    end
  end
end
checking.each do |movie|
  movie[:dates].each do |date|
    hash = {}
    hash[:title] = movie[:title]
    hash[:date] = date
    hash[:times] = movie[:times]
    final_array << hash
  end
end

# x = 110
# pp checking.drop(x).take(10)

# pp checking
pp final_array
pp final_array.size

# Send the full date string to the dates method and return an array, then iterate over the dates.

# pp shimo_dates("3/17(日)、21(木) 14：30〜(終15：50)")
