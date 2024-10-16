require "open-uri"
require "json"
require "nokogiri"
require "net/http"
require "dotenv/load"
require "date"

file = "new_cinema.html"
content = File.open(file, "r:shift_jis").read
utf8_content = content.encode("UTF-8", "Shift_JIS", invalid: :replace, undef: :replace, replace: "")
html = Nokogiri::HTML(utf8_content)
# html = Nokogiri::HTML.parse(html_content, nil, "shift_jis")
html = Nokogiri::HTML.parse(File.open(file), nil, "utf-8")
# html = Nokogiri::HTML.parse(File.open(file, "rb"), nil, "shift_jis")

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
      .sub(/ 4Ｋ$/, "")
      .sub(/ 2Kレストア版.*/, "")
      .sub(/2本目割./, "")
      .sub(/デジタル修復版.*/, "")
      .strip
  end
end

def cinema_dates(string)
  dates = []
  # month = string.split("/").first.to_i
  # match_data = string.match(/\/(.+)$/)
  # integers = []

  # if match_data
  #   integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
  # end

  # integers.each_with_index do |day, index|
  #   month += 1 if day < integers[integers.index(day) - 1] && !index.zero?
  #   dates << Date.new(Date.today.year, month, day) unless day == 0
  #   month -= 1 if day < integers[integers.index(day) - 1] unless index.zero?
  # end

  # if string.include?("～") || string.include?("〜")
  #   if dates[1]
  #     date_range = (dates[0]..dates[1])
  #     dates = date_range.to_a
  #   end
  # end
  dates
end

results = []

def bungeiza_showings(doc)
  results = []
  final = []
  doc.search(".schedule-content-inner").each do |box|
    next if box.at("h2").nil?

    month = box.at("h2").text.strip.split("/").first.to_i
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

hashes = bungeiza_showings(html)

hashes.each do |hash|
  pp hash[:date]
end

# html.search(".time_title").each do |element|
#   # html.search(".date").each do |element|
#   search_results << element.text.strip unless search_results.include?(element.text.strip)
# end
# puts html.to_html


def cinema_showings(doc)
  result = []
  # doc.search(".box").each do |table|
  #   date_text = table.search(".day").text
  #   dates = sho_dates(date_text)
  #   heads = table.search(".schedule-item")
  #   heads.each do |row|
  #     dates.each do |date|
  #       hash = {}
  #       hash[:date] = date
  #       hash[:name] = clean_titles([row.at("th").text.strip])[0]
  #       hash[:times] = row.css("td").map(&:text).reject { |string| string == "" }.map! { |time| time.sub(/～.*/, "") }
  #       result << hash if hash[:name]
  #     end
  #   end
  # end
  result
end

def movie_api_call(list)
  api_key = ENV["TMDB_API_KEY"]
  found = []
  not_found = []
  checking = []
  # languages = JSON.parse(ENV["LANGUAGES"])
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
      # language = languages.fetch(movie_data[0]["original_language"], movie_data[0]["original_language"])
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
      found << scraped_title
    else
      not_found << scraped_title
      not_found = not_found.each { |title| title.split("   ")[0].strip unless title.split("   ")[0].nil? }
    end
  }
  # puts "*" * 40 + "Found Movies"
  # found.each do |title|
  #   puts title
  # end
  puts "NOT Found Movies" + "*" * 40
  not_found.each do |title|
    puts title if found.empty?
    puts "#{title.split("  ")[0]}"
    # puts "#{title.split("  ")[-1]}"
    # puts "#{title.split("  ")}"
  end
  puts not_found.size
  movie_api_call(not_found) unless found.empty?
end

def kjo_showings(doc)
  result = []
  days = doc.search(".list-calendar-wrap")
  days.each do |day|
    date_text = day.search(".list-calendar-header-inner").text.strip[0, 5]
    date = Date.new(Date.today.year, date_text[0, 2].to_i, date_text[3, 2].to_i)
    date = date.next_year if date < (Date.today << 1)
    # Iterated through dates, now need to iterate through movie titles
    day.search(".tagged-film").each do |movie|
      title = movie.search(".list-calendar-heading").text.strip
      times = []
      movie.search(".list-calendar-date").each { |x| times << x.text.strip.split("—")[0] }
      result << { name: title, times: times, date: date }
    end
  end
  result
end
