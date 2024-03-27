require "open-uri"
require "json"
require "nokogiri"

def clean_titles(list)
  list.map! do |str|
    str.sub(/4K.*/, "")
       .sub(/デジタルリマスター.*/, "")
       .sub(/＋.*/, "")
       .sub(/　.*/, "")
       .sub(/★.*/, " ")
       .sub(/\n/, "")
       .sub(/【レイトショー】/, "")
       .strip
  end
end

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
      dates.each do |date|
        hash = {}
        hash[:date] = date
        hash[:name] = clean_titles([row.at("th").text.strip])[0]
        hash[:times] = row.css("td").map(&:text).reject { |string| string == "" }.map! { |time| time.sub(/～.*/, "") }
        result << hash if hash[:name]
      end
    end
  end
  result
end
