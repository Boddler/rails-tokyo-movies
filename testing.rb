require "net/http"
require "json"
require "dotenv/load"
require "date"
require "nokogiri"
require "open-uri"

html_content = URI.open("http://www.okura-movie.co.jp/meguro_cinema/now_showing.html")
doc = Nokogiri::HTML.parse(html_content, nil, "shift-JIS")


@search_results = []

doc.search(".time_title").each do |element|
  @search_results << element.text.strip unless @search_results.include?(element.text.strip)
end

@search_results.map! { |str| str.sub(/4K.*/, "") }
@search_results.map! { |str| str.sub(/デジタルリマスター.*/, "") }
@search_results.map! { |str| str.sub(/＋.*/, "") }

@directors = []

def directors(array)
  api_key = ENV["TMDB_API_KEY"]
  array.each do |id|
    credits_url = URI("https://api.themoviedb.org/3/movie/#{id}/credits?api_key=#{api_key}")
    credits_response = Net::HTTP.get(credits_url)
    credits_data = JSON.parse(credits_response)
    director = (credits_data["crew"].find { |person| person["job"] == "Director" }.nil? ? "Unknown" : credits_data["crew"].find { |person| person["job"] == "Director" }["name"])
    @directors << director
  end
  @directors
end

def ids(titles)
  api_key = ENV["TMDB_API_KEY"]
  ids =[]
  titles.each do |title|
    encoded_title = URI.encode_www_form_component(title)
    url = URI("https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{encoded_title}&language=en-gb")
    response = Net::HTTP.get(url)
    movie_json = JSON.parse(response)
    movie_data = movie_json["results"]
    movie_data.each { |reply| ids << reply["id"] }
  end
  directors(ids)
end

pp ids(@search_results).sort
