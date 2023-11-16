require "net/http"
require "json"
require "dotenv/load"
require "date"
require "nokogiri"
require "open-uri"
# require_relative "../cnm_meguro"

api_key = ENV["TMDB_API_KEY"]

file = "meguro6.html"
doc = Nokogiri::HTML.parse(File.open(file), nil, "shift-JIS")

Movie.destroy_all
puts "Movies deleted"
Cinema.destroy_all
puts "Cinemas deleted"
Showing.destroy_all
puts "Showings deleted"

cinema_1 = Cinema.new(
  name: "Meguro Cinema",
  location: "〒141-0021 東京都品川区上大崎２丁目２４−１５ 朝日建物株式会社 目黒西口ビル B1",
  url: "http://www.okura-movie.co.jp/meguro_cinema/now_showing.html",
  description: "A small, single screen cinema showing old and new movies.",
)
cinema_1.save

cinema_2 = Cinema.new(
  name: "Kawasaki Art Centre",
  location: "〒215-0004 神奈川県川崎市麻生区万福寺６丁目７−１",
  url: "https://kac-cinema.jp/",
  description: "A cinema focused on European movies.",
)
cinema_2.save

@search_results = []
@movie_times = []

# Meguro Cinema Movie List Scrape
doc.search(".time_title").each do |element|
  @search_results << element.text.strip
end

puts "#{@search_results.uniq.size} unique movies found"
puts "#{@search_results.size} total movies found"
@not_found = []

def movie_api_call(list)
  api_key = ENV["TMDB_API_KEY"]
  languages_JSON = ENV["LANGUAGES"]
  languages = JSON.parse(languages_JSON)
  list.map! { |str| str.gsub(/4Kレストア版/, "") }
  list.uniq.each { |scraped_title|
    cast = []

    encoded_title = URI.encode_www_form_component(scraped_title)
    url = URI("https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{encoded_title}&language=en-gb")
    response = Net::HTTP.get(url)
    movie_data = JSON.parse(response)

    if movie_data["results"].any?
      title = movie_data["results"][0]["title"]
      overview = movie_data["results"][0]["overview"]
      language = languages.fetch(movie_data["results"][0]["original_language"], movie_data["results"][0]["original_language"])
      poster = movie_data["results"][0]["poster_path"]
      year = movie_data["results"][0]["release_date"]
      id = movie_data["results"][0]["id"]
      popularity = movie_data["results"][0]["popularity"]
      credits_url = URI("https://api.themoviedb.org/3/movie/#{movie_data["results"][0]["id"]}/credits?api_key=#{api_key}")
      credits_response = Net::HTTP.get(credits_url)
      credits_data = JSON.parse(credits_response)

      runtime_url = URI("https://api.themoviedb.org/3/movie/#{id}?&append_to_response=videos&api_key=#{api_key}")
      runtime_response = Net::HTTP.get(runtime_url)
      detailed_data = JSON.parse(runtime_response)
      runtime = detailed_data["runtime"]
      director = credits_data["crew"].find { |person| person["job"] == "Director" }["name"]
      x = 0
      10.times do
        cast << credits_data["cast"][x]["name"] if credits_data["cast"][x] && credits_data["cast"][x]["name"]
        x += 1
      end
      background_url = URI("https://api.themoviedb.org/3/movie/#{id}/images?api_key=#{api_key}")
      background_response = Net::HTTP.get(background_url)
      background_data = JSON.parse(background_response)
      background = (background_data["backdrops"][0].nil? ? "https://www.themoviedb.org/t/p/original/bm2pU9rfFOhuHrzMciV6NlfcSeO.jpg" : background_data["backdrops"][0])
      new_movie = Movie.new(director: director, popularity: popularity, runtime: runtime, name: title, description: overview,
                            web_title: scraped_title, year: year, cast: cast, language: language, poster: "https://image.tmdb.org/t/p/w185/#{poster}",
                            background: background)
      puts new_movie.save ? "#{title}" + (title.length > 39 ? " " : " " * (40 - title.length)) + "saved successfully" : "Error when saving-----------------------"
    else
      @not_found << scraped_title
      puts "Movie not found"
    end
  }
end

movie_api_call(@search_results)

@not_found.each { |x| puts "#{x} not found" }
puts @not_found.size.positive? ? "#{@not_found.size} movies not found in total" : "All movies found"
# @movie_times.each { |x| puts x }

def date(date_string)
  if date_string.include?("〜")
    date_ranges = date_string.scan(/(\d{1,2})月(\d{1,2})日/)
    start_date = Date.new(Date.today.year, date_ranges[0][0].to_i, date_ranges[0][1].to_i)
    end_date = Date.new(Date.today.year, date_ranges[-1][0].to_i, date_ranges[-1][1].to_i)
    (start_date..end_date).to_a
  else
    date_ranges = date_string.scan(/(\d{1,2})月(\d{1,2})日/)
    return [] if date_ranges.empty?

    date_ranges.map do |matches|
      start_month = matches[0].to_i
      start_day = matches[1].to_i
      Date.new(Date.today.year, start_month, start_day)
    end
  end
end

result = []

doc.search("#timetable").each do |line|
  dates = date(line.css("p").text)
  line.css(".time_box tr").each do |row|
    title = row.css(".time_title").text.strip
    times = row.css(".time_type2").map { |el| el.text.strip }
    times.each do |time|
      start_time = time.match(/(0?[0-9]|1[0-9]|2[0-3]):[0-5][0-9]/)
      if start_time && dates.size > 0
        dates.each do |date|
          matching_hash = result.find { |hash| hash[:name] == title && hash[:date] == date }
          if matching_hash
            matching_hash[:times] ||= []
            matching_hash[:times] << start_time[0]
          else
            result << { name: title, times: [start_time[0]], date: date }
          end
        end
      end
    end
  end
end

result.each do |date|
  movie = Movie.all.find { |movie| movie.web_title == date[:name] }
  if movie
    showing = Showing.new(date: date[:date], times: date[:times], movie_id: movie.id, cinema_id: Cinema.all.first.id)
    if showing.save
      p showing
      puts "#{movie.name} saved successfully"
    else
      puts "#{movie} not saved"
      puts "Errors: #{movie.errors.full_messages}"
    end
  else
    puts "No movie found"
  end
end
