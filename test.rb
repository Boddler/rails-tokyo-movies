require "open-uri"
require "json"
require "nokogiri"
require "net/http"
require "dotenv/load"
require "date"

file = "new_cinema.html"
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
      .sub(/2本目割./, "")
      .strip
  end
end

def showing_create(doc)
  results = []
  final = []
  doc.search(".schedule-content-inner").each do |box|
    month = box.at("h2").text.strip[0].to_i
    day = 0
    box.search(".schedule-program").each do |line|
      if line.previous_element.name == "h2"
        new = line.previous_element.text.strip.match(/(\d+)（/)
        month += 1 if new && (new[1].to_i < day)
        day = new[1].to_i if new
        # add logic here to increment the month if day is lower than before
      end
      movie = line.at("p").children.select { |node| node.text? }.map(&:text).reject { |str| str.strip == "" }
      movie = line.at("a").children.select { |node| node.text? }.map(&:text).reject { |str| str.strip == "" } if movie[0].nil?
      time = line.search("li").text.strip
      movie = movie[0].split("＋") if movie[0].include?("＋")
      results << [month, day, clean_titles(movie), time[0..4], month]
      month -= 1 if new && (new[1].to_i < day)
    end
  end
  # p dates = line.text.strip
  # results << dates
  results.each do |result|
    result[2].each_with_index do |movie, index|
      hash = {}
      hash[:name] = movie
      hash[:times] = [result[3] + ("*" unless index.zero?).to_s]
      hash[:date] = Date.new(Date.today.year, result[4], result[1])
      final << hash
    end
  end
  final
end

x = showing_create(html)

# pp x.select { |str| str.include?("/") }
# pp x.select { |str| str.include?("/") }.size
x.each do |y|
  pp y if y[:times][0].include?("*")
end

pp x.size
# results.each do |x|
# end
