require "open-uri"
require "json"
require "nokogiri"
require "net/http"
require "dotenv/load"
require "date"

file = "new_cinema.html"
html = Nokogiri::HTML.parse(File.open(file), nil, "utf-8")

MOVIES = ["ナチュラル",
          "恋におちて",
          "花腐し",
          "春画先生",
          "春の画 SHUNGA",
          "ポトフ 美食家と料理人",
          "愛と哀しみの果て",
          "後継者",
          "火の道",
          "サルカール 1票の革命",
          "Puli",
          "ソナチネ",
          "GONIN",
          "暗黒街の顔役",
          "暗黒街の対決",
          "遺灰は語る",
          "結婚のすべて",
          "若い娘たち",
          "奇跡",
          "吸血鬼",
          "あるじ",
          "暗黒街の弾痕",
          "地獄の饗宴（うたげ）",
          "裁かるゝジャンヌ",
          "ミカエル",
          "大学の山賊たち",
          "月給泥棒",
          "怒りの日",
          "ゲアトルーズ",
          "独立愚連隊",
          "独立愚連隊西へ",
          "月",
          "愛にイナズマ",
          "きっと、それは愛じゃない",
          "私がやりました",
          "悪い子バビー",
          "ディンゴ",
          "悪魔の狂暴パニック",
          "トラウマ 鮮血の叫び",
          "ナイトメア",
          "ジュリア 幽霊と遊ぶ女",
          "裏切りのサーカス",
          "ジェヴォーダンの獣",
          "グラディエーター",
          "愛していると伝えて",
          "講義",
          "大事なのは愛すること",
          "BLOOD THE LAST VAMPIRE",
          "人狼 JIN-ROH",
          "イバニエズの激流",
          "肉体と悪魔",
          "マエストロ：その音楽と愛と",
          "TAR ター",
          "骨",
          "オオカミの家",
          "ブンミおじさんの森",
          "光りの墓",
          "MEMORIA メモリア",
          "さらば、わが愛／覇王別姫",
          "劇場版 うたの☆プリンスさまっ♪ マジLOVEスターリッシュツアーズ",
          "幻の湖",
          "レッド・スコルピオン",
          "メン・オブ・ウォー",
          "伽倻子のために",
          "眠る男"]

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
    day = ""
    box.search(".schedule-program").each do |line|
      if line.previous_element.name == "h2"
        new = line.previous_element.text.strip.match(/(\d+)（/)
        day = new[1].to_i if new
        # add logic here to increment the month if day is lower than before
      end
      movie = line.at("p").children.select { |node| node.text? }.map(&:text).reject { |str| str.strip == "" }
      movie = line.at("a").children.select { |node| node.text? }.map(&:text).reject { |str| str.strip == "" } if movie[0].nil?
      time = line.search("li").text.strip
      movie = movie[0].split("＋")
      results << [month, day, clean_titles(movie), time[0..4], month]
    end
  end
  # p dates = line.text.strip
  # results << dates
  results.each do |result|
    result[2].each do |movie|
      hash = {}
      hash[:name] = movie
      hash[:times] = [result[3]]
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
  pp y
end

pp x.size
# results.each do |x|
# end
