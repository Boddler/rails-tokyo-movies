module UpdateHelper
  require "open-uri"
  require "json"
  require "nokogiri"

  def clean_titles(list)
    list.map! { |str| str.sub(/4K.*/, "") }
    list.map! { |str| str.sub(/デジタルリマスター.*/, "") }
    list.map! { |str| str.sub(/＋.*/, "") }
  end

  def first_api_call(list)
    movie_data = []
    list.uniq.each do |title|
      encoded_title = URI.encode_www_form_component("\"#{title}\"")
      url = URI("https://api.themoviedb.org/3/search/movie?api_key=#{ENV["TMDB_API_KEY"]}&query=#{encoded_title}&language=en-gb")
      response = Net::HTTP.get(url)
      movie_json = JSON.parse(response)
      movie_data << [movie_json["results"].sort_by { |movie| -movie["vote_count"].to_f }, title]
    end
    movie_data
  end

  def scrape(cinema)
    search_results = []
    html_content = URI.open(cinema.schedule)
    doc = Nokogiri::HTML.parse(html_content, nil, cinema.encoding)
    # Need to add conditional calling contingent on the cinema here
    doc.search(".time_title").each do |element|
      search_results << element.text.strip unless search_results.include?(element.text.strip)
    end
    clean_titles(search_results)
    # clean_titles(search_results)
  end

  def group_call(results)
    languages = JSON.parse(ENV["LANGUAGES"])
    results.each do |movie|
      if movie.nil? || !movie[0].empty?
        hash = {}
        hash[:title] = movie[0][0]["title"]
        hash[:overview] = movie[0][0]["overview"]
        hash[:language] = languages.fetch(movie[0][0]["original_language"], movie[0][0]["original_language"])
        hash[:poster] = movie[0][0]["poster_path"]
        hash[:year] = movie[0][0]["release_date"]
        hash[:id] = movie[0][0]["id"]
        hash[:popularity] = movie[0][0]["popularity"]
        people = crew(hash[:id])
        hash[:cast] = people[0]
        hash[:scraped_title] = movie[1]
        hash[:director] = people[1]
        hash[:runtime] = runtime(hash[:id])
        hash[:backgrounds] = backgrounds(hash[:id])
        movie_create(hash)
      end
    end
  end

  def crew(id)
    cast = []
    credits_url = URI("https://api.themoviedb.org/3/movie/#{id}/credits?api_key=#{ENV["TMDB_API_KEY"]}")
    credits_response = Net::HTTP.get(credits_url)
    credits_data = JSON.parse(credits_response)
    x = 0
    10.times do
      cast << credits_data["cast"][x]["name"] if credits_data["cast"][x] && credits_data["cast"][x]["name"]
      x += 1
    end
    director = (credits_data["crew"].find { |person| person["job"] == "Director" }.nil? ? "Unknown" : credits_data["crew"].find { |person| person["job"] == "Director" }["name"])
    [cast, director]
  end

  def runtime(id)
    runtime_url = URI("https://api.themoviedb.org/3/movie/#{id}?&append_to_response=videos&api_key=#{ENV["TMDB_API_KEY"]}")
    runtime_response = Net::HTTP.get(runtime_url)
    detailed_data = JSON.parse(runtime_response)
    detailed_data["runtime"]
  end

  def backgrounds(id)
    background_url = URI("https://api.themoviedb.org/3/movie/#{id}/images?api_key=#{ENV["TMDB_API_KEY"]}")
    background_response = Net::HTTP.get(background_url)
    background_data = JSON.parse(background_response)
    background_data["backdrops"].nil? ? nil : background_data["backdrops"]
  end

  def movie_create(info)
    new_movie = Movie.new(director: info[:director], popularity: info[:popularity], runtime: info[:runtime], name: info[:title], description: info[:overview],
                          web_title: info[:scraped_title], year: info[:year], cast: info[:cast], language: info[:language], poster: "https://image.tmdb.org/t/p/w185/#{info[:poster]}",
                          backgrounds: info[:backgrounds])
    new_movie.save
  end

  def showings(cinema)
    result = []
    html_content = URI.open(cinema.schedule)
    doc = Nokogiri::HTML.parse(html_content, nil, cinema.encoding)
    doc.search("#timetable").each do |line|
      dates = date(line.css("p").text)
      line.css(".time_box tr").each do |row|
        title = row.css(".time_title").text.strip
        times = row.css(".time_type2").map { |el| el.text.strip }
        times.each do |time|
          start_time = time.match(/(0?[0-9]|1[0-9]|2[0-3]):[0-5][0-9]/)
          if start_time && dates.size.positive?
            dates.each do |date|
              title = clean_titles([title])[0]
              # title = title.sub(/4K.*/, "")
              # title = title.sub(/デジタルリマスター.*/, "")
              # title = title.sub(/＋.*/, "")
              matching_hash = result.find { |hash| hash[:name] == title && hash[:date] == date }
              if matching_hash
                matching_hash[:times] ||= []
                matching_hash[:times] << start_time[0] unless matching_hash[:times].include?(start_time[0])
              else
                result << { name: title, times: [start_time[0]], date: date }
              end
            end
          end
        end
      end
    end
    result
  end

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

  def showing_create(array, cinema)
    array.each do |date|
      movie = Movie.all.find { |film| film.web_title == date[:name] }
      if movie
        showing = Showing.new(date: date[:date], times: date[:times], movie_id: movie.id, cinema_id: cinema.id)
        showing.save
      end
    end
  end
end
