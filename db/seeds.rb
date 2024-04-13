require "net/http"
require "json"
require "date"
require "nokogiri"
require "open-uri"

# html_content = URI.open("http://www.okura-movie.co.jp/meguro_cinema/now_showing.html")
# doc = Nokogiri::HTML.parse(html_content, nil, "shift-JIS")

Movie.destroy_all
puts "Movies deleted"
Cinema.destroy_all
puts "Cinemas deleted"
Showing.destroy_all
puts "Showings deleted"

cinema = Cinema.new(
  name: "Meguro Cinema",
  location: "〒141-0021 東京都品川区上大崎２丁目２４−１５ 朝日建物株式会社 目黒西口ビル B1",
  url: "http://www.okura-movie.co.jp/meguro_cinema/now_showing.html",
  schedule: "http://www.okura-movie.co.jp/meguro_cinema/now_showing.html",
  description: "A small, single screen cinema showing old and new movies.",
  encoding: "shift-JIS",
  map: "https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d3278.5069178227864!2d139.71336906447036!3d35.634574030623185!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x60188b19055c8655%3A0xaba33b9365f206fe!2sMeguro%20Cinema!5e0!3m2!1sen!2sjp!4v1705662015979!5m2!1sen!2sjp",
)
cinema.save

cinema = Cinema.new(
  name: "Waseda Shochiku",
  location: "〒169-0075 新宿区高田馬場1-5-16",
  url: "http://wasedashochiku.co.jp/",
  schedule: "http://wasedashochiku.co.jp/",
  description: "Waseda Shochiku is a cinema in Takadanobaba.
  Waseda Shochiku screens movies that have finished their roadshows
  and past masterpieces in double features.",
  encoding: "utf-8",
  map: "https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d6479.1860777786615!2d139.708209!3d35.711631!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x60188d3c44e28145%3A0x7d13a0b5b4274512!2sWaseda%20Sh%C5%8Dchiku!5e0!3m2!1sen!2sus!4v1711435923714!5m2!1sen!2sus",
)
cinema.save

cinema = Cinema.new(
  name: "Shimo-Takaido Cinema",
  location: "〒156-0043 世田谷区松原 3-27-26-2F",
  url: "http://www.shimotakaidocinema.com/index.html",
  schedule: "http://www.shimotakaidocinema.com/schedule/schedule.html",
  description: "A cinema in Shimo Takaido with no discernable about section on its website...",
  encoding: "utf-8",
  map: "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3241.449792322695!2d139.6401235760827!3d35.665925272592126!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x6018f3af070c47bb%3A0xb940ca5acadedabb!2sShimo-Takaido%20Cinema!5e0!3m2!1sen!2sjp!4v1711627245141!5m2!1sen!2sjp",
)
cinema.save

cinema = Cinema.new(
  name: "Shin-Bungeiza",
  location: "〒170-0013 東京都豊島区東池袋1-43-5 マルハン池袋ビル3F",
  url: "https://www.shin-bungeiza.com/",
  schedule: "https://www.shin-bungeiza.com/schedule",
  description: "A cinema in Ikebukuro with no discernable about section on its website...",
  encoding: "utf-8",
  map: "https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d6477.660774182871!2d139.7109076!3d35.7303897!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x60188d67188625bd%3A0x72bec5cfc1d19bb!2sShin-Bungeiza!5e0!3m2!1sen!2sjp!4v1712543096694!5m2!1sen!2sjp",
)
cinema.save

# cinema = Cinema.new(
#   name: "Kawasaki ",
#   location: "〒215-0004 神奈川県川崎市麻生区万福寺６丁目７−１",
#   url: "https://kac-cinema.jp/",
#   schedule: "https://kac-cinema.jp/schedule/",
#   description: "A cinema focused on European movies.",
#   encoding: "shift-JIS",
# )
# cinema.save

# @search_results = []
# @movie_times = []

# # Meguro Cinema Movie List Scrape
# doc.search(".time_title").each do |element|
#   @search_results << element.text.strip unless @search_results.include?(element.text.strip)
# end

# puts "#{@search_results.size} unique movies found"
# @not_found = []

# def movie_api_call(list)
#   api_key = ENV["TMDB_API_KEY"]
#   languages = JSON.parse(ENV["LANGUAGES"])
#   list.map! { |str| str.sub(/4K.*/, "") }
#   list.map! { |str| str.sub(/デジタルリマスター.*/, "") }
#   list.map! { |str| str.sub(/＋.*/, "") }
#   list.uniq.each { |scraped_title|
#     cast = []

#     # encoded_title = URI.encode_www_form_component(scraped_title)
#     encoded_title = URI.encode_www_form_component("\"#{scraped_title}\"") # checks the quoted title - more precise but might miss stuff?
#     url = URI("https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{encoded_title}&language=en-gb")
#     response = Net::HTTP.get(url)
#     movie_json = JSON.parse(response)
#     movie_data = movie_json["results"]
#     movie_data = movie_data.sort_by { |movie| -movie["vote_count"].to_f }

#     if movie_data.any?
#       title = movie_data[0]["title"]
#       overview = movie_data[0]["overview"]
#       language = languages.fetch(movie_data[0]["original_language"], movie_data[0]["original_language"])
#       poster = movie_data[0]["poster_path"]
#       year = movie_data[0]["release_date"]
#       id = movie_data[0]["id"]
#       popularity = movie_data[0]["popularity"]
#       credits_url = URI("https://api.themoviedb.org/3/movie/#{movie_data[0]["id"]}/credits?api_key=#{api_key}")
#       credits_response = Net::HTTP.get(credits_url)
#       credits_data = JSON.parse(credits_response)

#       runtime_url = URI("https://api.themoviedb.org/3/movie/#{id}?&append_to_response=videos&api_key=#{api_key}")
#       runtime_response = Net::HTTP.get(runtime_url)
#       detailed_data = JSON.parse(runtime_response)
#       runtime = detailed_data["runtime"]
#       director = (credits_data["crew"].find { |person| person["job"] == "Director" }.nil? ? "Unknown" : credits_data["crew"].find { |person| person["job"] == "Director" }["name"])

#       x = 0
#       10.times do
#         cast << credits_data["cast"][x]["name"] if credits_data["cast"][x] && credits_data["cast"][x]["name"]
#         x += 1
#       end
#       background_url = URI("https://api.themoviedb.org/3/movie/#{id}/images?api_key=#{api_key}")
#       background_response = Net::HTTP.get(background_url)
#       background_data = JSON.parse(background_response)
#       # background = (background_data["backdrops"][0].nil? ? "https://www.themoviedb.org/t/p/original/bm2pU9rfFOhuHrzMciV6NlfcSeO.jpg" : background_data["backdrops"][0])
#       background = (background_data["backdrops"].nil? ? nil : background_data["backdrops"])
#       new_movie = Movie.new(director: director, popularity: popularity, runtime: runtime, name: title, description: overview,
#                             web_title: scraped_title, year: year, cast: cast, language: language, poster: "https://image.tmdb.org/t/p/w185/#{poster}",
#                             backgrounds: background)
#       puts new_movie.save ? "#{title}" + (title.length > 69 ? " " : " " * (70 - title.length)) + "saved successfully" : "Error when saving-----------------------"
#     else
#       @not_found << scraped_title
#       puts "Movie not found"
#     end
#   }
# end

# movie_api_call(@search_results)

# @not_found.each { |x| puts "#{x} not found" }
# puts @not_found.size.positive? ? "#{@not_found.size} movies not found in total" : "All movies found"
# # @movie_times.each { |x| puts x }

# def date(date_string)
#   if date_string.include?("〜")
#     date_ranges = date_string.scan(/(\d{1,2})月(\d{1,2})日/)
#     start_date = Date.new(Date.today.year, date_ranges[0][0].to_i, date_ranges[0][1].to_i)
#     end_date = Date.new(Date.today.year, date_ranges[-1][0].to_i, date_ranges[-1][1].to_i)
#     (start_date..end_date).to_a
#   else
#     date_ranges = date_string.scan(/(\d{1,2})月(\d{1,2})日/)
#     return [] if date_ranges.empty?

#     date_ranges.map do |matches|
#       start_month = matches[0].to_i
#       start_day = matches[1].to_i
#       Date.new(Date.today.year, start_month, start_day)
#     end
#   end
# end

# result = []

# doc.search("#timetable").each do |line|
#   dates = date(line.css("p").text)
#   line.css(".time_box tr").each do |row|
#     title = row.css(".time_title").text.strip
#     times = row.css(".time_type2").map { |el| el.text.strip }
#     times.each do |time|
#       start_time = time.match(/(0?[0-9]|1[0-9]|2[0-3]):[0-5][0-9]/)
#       if start_time && dates.size.positive?
#         dates.each do |date|
#           title = title.sub(/4K.*/, "")
#           title = title.sub(/デジタルリマスター.*/, "")
#           title = title.sub(/＋.*/, "")
#           matching_hash = result.find { |hash| hash[:name] == title && hash[:date] == date }
#           if matching_hash
#             matching_hash[:times] ||= []
#             matching_hash[:times] << start_time[0] unless matching_hash[:times].include?(start_time[0])
#           else
#             result << { name: title, times: [start_time[0]], date: date }
#           end
#         end
#       end
#     end
#   end
# end

# result.each do |date|
#   movie = Movie.all.find { |film| film.web_title == date[:name] }
#   if movie
#     showing = Showing.new(date: date[:date], times: date[:times], movie_id: movie.id, cinema_id: Cinema.all.first.id)
#     puts "Errors: #{movie.errors.full_messages}" unless showing.save
#   end
# end
