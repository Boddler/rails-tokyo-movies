require "open-uri"
require "json"
require "nokogiri"
require "net/http"
require "dotenv/load"

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

def showing_create(doc)
  results = []
  doc.search(".schedule-content-inner").each do |box|
    p month = box.css("h2").text.strip[0].to_i
    box.each do |line|
      date = box.css
    end
    # p dates = line.text.strip
    # results << dates
  end
  results
end

x = showing_create(html)

# pp x.select { |str| str.include?("/") }
# pp x.select { |str| str.include?("/") }.size
pp x.size
