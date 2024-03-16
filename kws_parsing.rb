require "net/http"
require "json"
require "dotenv/load"
require "date"
require "nokogiri"
require "open-uri"
# require_relative "config/environment"

def clean_titles(list)
  list.map! do |str|
    str.sub(/4K.*/, "")
       .sub(/デジタルリマスター.*/, "")
       .sub(/＋.*/, "")
       .sub(/　.*/, "")
       .sub(/\n/, "")
       .strip
  end
end

file = "kws.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "shift-JIS")

texts = doc.search(".inner a").map { |link| link.text.strip }
texts = clean_titles(texts)
texts.map { |title| title.strip }

pp clean_titles(texts.uniq)
puts "-" * 40
pp texts.uniq
puts "-" * 40

p clean_titles(texts.uniq) == texts.uniq
