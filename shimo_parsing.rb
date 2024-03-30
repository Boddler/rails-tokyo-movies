require "open-uri"
require "json"
require "nokogiri"
require "net/http"
require "dotenv/load"

file = "shimo.html"
html = Nokogiri::HTML.parse(File.open(file), nil, "utf-8")

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

def shimo_dates(string)
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

  if string.include?("～") || string.include?("〜")
    if dates[1]
      date_range = (dates[0]..dates[1])
      dates = date_range.to_a
    end
  end
  # if string.include?("〜")
  #   if dates[1]
  #     date_range = (dates[0]..dates[1])
  #     dates = date_range.to_a
  #   end
  # end

  dates
end

def shimo_showings(doc)
  result = []
  doc.search(".box").each do |table|
    date_text = table.search(".day").text
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

checking = []

html.search(".box").each do |element|
  unless element.search(".day").first.nil?
    hash = {}
    hash[:title] = element.search(".eiga-title").first.text.strip unless element.search(".eiga-title").first.nil?
    hash[:date] = element.search(".day").first.text.strip # unless element.search(".eiga-title").first.text.strip.nil?
    checking << hash
  end
end

checking.each do |cell|
  # p cell[:title] unless cell[:title].nil?
  # p cell[:date] unless cell[:title].nil?
  # p "*" * 40 unless cell[:title].nil?
end

string = "3/16(土)〜3/22(金) 16：05〜(終18：11)\n" + "\t\t  3/23(土)〜3/29(金) 12：05〜(終14：11)"

# pp shimo_dates(string)

ng1 = "3/9(土) 16:00〜(終17:55)\n" + "\t\t\t3/11(月) 17:55〜(終19:50)\n" + "\t\t\t3/15(金) 17:50〜(終19:45)\n" + "\t\t\t3/17(日) 20:10〜(終22:05)"
ng2 = "3/16(土)、18(月)〜20(水)、22(金) 14：30〜(終15：52)"
ng3 = "3/17(日)、21(木) 14：30〜(終15：50)"
ng4 = "3/16(土)〜3/22(金) 16：05〜(終18：11)\n" + "\t\t  3/23(土)〜3/29(金) 12：05〜(終14：11)"

dates = ["4/20(土) 19:45〜(終20:30)\n\t\t\t4/23(火) 21:00〜(終21:45)"]

dates.each do |date|
  pp shimo_dates(date)
end
