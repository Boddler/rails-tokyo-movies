require "open-uri"
require "json"
require "nokogiri"
require "net/http"
require "dotenv/load"

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

def cinema_dates(string)
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
  dates
end

def cinema_showings(doc)
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

p_element = html.search(".schedule-program p")
titles = p_element.children.select { |node| node.text? }.map(&:text).reject { |str| str.strip == "" }
p titles

def movie_api_call(list)
  api_key = ENV["TMDB_API_KEY"]
  checking = []
  languages = JSON.parse(ENV["LANGUAGES"])
  list = clean_titles(list)
  list.uniq.each { |scraped_title|
    cast = []
    encoded_title = URI.encode_www_form_component("\"#{scraped_title}\"") # checks the quoted title - more precise but might miss stuff?
    url = URI("https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{encoded_title}&language=en-gb")
    response = Net::HTTP.get(url)
    movie_json = JSON.parse(response)
    movie_data = movie_json["results"]
    movie_data = movie_data.sort_by { |movie| -movie["vote_count"].to_f }
    if movie_data.any?
      title = movie_data[0]["title"]
      overview = movie_data[0]["overview"]
      # language = movie_data[0].spoken_languages[0]
      poster = movie_data[0]["poster_path"] # unless movie_data[0]["poster_path"].nil?
      puts "#{title} has no poster path!******************" if movie_data[0]["poster_path"].nil?
      language = languages.fetch(movie_data[0]["original_language"], movie_data[0]["original_language"])
      year = movie_data[0]["release_date"]
      id = movie_data[0]["id"]
      popularity = movie_data[0]["popularity"]
      credits_url = URI("https://api.themoviedb.org/3/movie/#{movie_data[0]["id"]}/credits?api_key=#{api_key}")
      credits_response = Net::HTTP.get(credits_url)
      credits_data = JSON.parse(credits_response)

      runtime_url = URI("https://api.themoviedb.org/3/movie/#{id}?&append_to_response=videos&api_key=#{api_key}")
      runtime_response = Net::HTTP.get(runtime_url)
      detailed_data = JSON.parse(runtime_response)
      runtime = detailed_data["runtime"]
      director = (credits_data["crew"].find { |person| person["job"] == "Director" }.nil? ? "Unknown" : credits_data["crew"].find { |person| person["job"] == "Director" }["name"])

      x = 0
      10.times do
        cast << credits_data["cast"][x]["name"] if credits_data["cast"][x] && credits_data["cast"][x]["name"]
        x += 1
      end
      background_url = URI("https://api.themoviedb.org/3/movie/#{id}/images?api_key=#{api_key}")
      background_response = Net::HTTP.get(background_url)
      background_data = JSON.parse(background_response)
      # background = (background_data["backdrops"][0].nil? ? "https://www.themoviedb.org/t/p/original/bm2pU9rfFOhuHrzMciV6NlfcSeO.jpg" : background_data["backdrops"][0])
      background = (background_data["backdrops"].nil? ? nil : background_data["backdrops"])
      puts "#{title} found successfully"
    else
      puts "Movie not found: #{scraped_title} ***********************************************"
    end
  }
end

movie_api_call(titles)
cleaned_titles = clean_titles(titles).uniq
bleached_titles = cleaned_titles

# pp movie_api_call(bleached_titles)
# pp movie_api_call(bleached_titles).size
pp bleached_titles.size

# pp checking.drop(5).take(5)
