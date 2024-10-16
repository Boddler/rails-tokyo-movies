module UpdateHelper
  require "open-uri"
  require "json"
  require "nokogiri"

  def scrape(cinemas)
    titles_hash = {}
    cinemas.each do |cinema|
      html_content = URI.open(cinema.schedule)
      if cinema.name == "Meguro Cinema"
        utf8_content = html_content.read.encode("UTF-8", "Shift_JIS", invalid: :replace, undef: :replace, replace: "")
        doc = Nokogiri::HTML(utf8_content)
      else
        doc = Nokogiri::HTML.parse(html_content, nil, cinema.encoding)
      end
      search_results = cinema_scrape(doc, cinema.name)
      titles_hash[cinema.name.to_sym] = clean_titles(search_results)
    end
    titles_hash
  end

  def cinema_scrape(html, cinema)
    search_results = []
    case cinema
    when "Meguro Cinema"
      html.search(".time_title").each do |element|
        search_results << element.text.strip unless search_results.include?(element.text.strip)
      end
    when "Shimo-Takaido Cinema"
      html.search(".eiga-title").each do |element|
        search_results << element.text.strip unless search_results.include?(element.text.strip)
      end
    when "Waseda Shochiku"
      html.search(".schedule-item").each do |element|
        search_results << element.at("th").text.strip unless search_results.include?(element.at("th").text.strip)
      end
    when "Shin-Bungeiza"
      p_element = html.search(".schedule-program p")
      search_results = p_element.children.select { |node| node.text? }.map(&:text).reject { |str| str.strip == "" }
    when "Kichijoji Up Link"
      titles = html.search(".tagged-film h1")
      titles = titles.reject { |title| title.text.nil? }
      search_results = titles.map { |title| title.text.strip }
    end
    search_results.uniq
  end

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

  def first_api_call(list)
    movie_data = []
    list.each do |_, titles|
      titles.each do |title|
        encoded_title = URI.encode_www_form_component("\"#{title}\"")
        url = URI("https://api.themoviedb.org/3/search/movie?api_key=#{ENV["TMDB_API_KEY"]}&query=#{encoded_title}&language=en-gb")
        response = Net::HTTP.get(url)
        movie_json = JSON.parse(response)
        movie_data << [movie_json["results"].sort_by { |movie| -movie["vote_count"].to_f }, title]
      end
    end
    missing = movie_data.select { |array| array[0] == [] }.map { |array| array[1] }
    [movie_data, missing]
  end

  def group_call(results)
    languages = LANGUAGES
    unknown = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Question_mark_alternate.svg/1577px-Question_mark_alternate.svg.png"
    models_to_be_saved = []
    results.each do |movie|
      if movie.nil? || !movie[0].empty?
        hash = {}
        hash[:name] = movie[0][0]["title"]
        hash[:description] = movie[0][0]["overview"]
        hash[:language] = languages.fetch(movie[0][0]["original_language"].to_sym, movie[0][0]["original_language"])
        poster = movie[0][0]["poster_path"]
        hash[:poster] = poster.nil? ? unknown : "https://image.tmdb.org/t/p/w500/#{poster}"
        hash[:year] = movie[0][0]["release_date"]
        hash[:id] = movie[0][0]["id"]
        hash[:popularity] = movie[0][0]["popularity"]
        people = crew(hash[:id])
        unless people.nil?
          hash[:cast] = people[0]
          hash[:director] = people[1]
        end
        hash[:web_title] ||= []
        hash[:web_title] << movie[1]
        hash[:runtime] = runtime(hash[:id])
        hash[:backgrounds] = backgrounds(hash[:id])
        models_to_be_saved << hash
      end
    end
    models_to_be_saved
  end

  def movies_create(info, all_movies)
    existing_web_titles = all_movies.map(&:web_title).flatten.to_set
    info.each do |movie|
      unless existing_web_titles.include?(movie[:web_title][0])
        new_movie = Movie.new(director: movie[:director], popularity: movie[:popularity], runtime: movie[:runtime],
                              name: movie[:name], description: movie[:description],
                              web_title: movie[:web_title], year: movie[:year], cast: movie[:cast],
                              language: movie[:language], poster: movie[:poster], tmdb_id: movie[:id],
                              backgrounds: movie[:backgrounds])
        unless new_movie.save &&
               existing_movie = Movie.find_by(tmdb_id: new_movie.tmdb_id)
          if existing_movie
            existing_movie.web_title += new_movie.web_title unless existing_movie.web_title.include?(new_movie.web_title[0])
            existing_movie.update(web_title: existing_movie.web_title)
          else
            Rails.logger.error("Existing movie not found for tmdb_id: #{new_movie.tmdb_id}")
          end
        end
      end
    end
  end

  def unfound_movies(movies, all_movies)
    existing_web_titles = all_movies.map(&:web_title).flatten.to_set
    new_movies = movies.map do |movie|
      unless existing_web_titles.include?(movie)
        Movie.new(
          director: "Unknown",
          popularity: 0.0,
          runtime: nil,
          name: movie,
          description: "No match has been found for this movie",
          web_title: [movie],
          year: nil,
          cast: ["Unknown"],
          poster: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Question_mark_alternate.svg/1577px-Question_mark_alternate.svg.png",
          language: "Unknown",
          backgrounds: [],
          tmdb_id: -1,
        )
      end
    end.compact
    unique_movies = new_movies.uniq(&:name)
    unique_movies.each(&:save)
  end

  def blank_update(movie)
    default_values = {
      director: "Unknown",
      popularity: 0.0,
      runtime: nil,
      name: movie.web_title[0],
      description: "No match has been found for this movie",
      year: nil,
      tmdb_id: 0,
      cast: ["Unknown"],
      poster: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Question_mark_alternate.svg/1577px-Question_mark_alternate.svg.png",
      language: "Unknown",
      backgrounds: [],
    }
    if movie.update(default_values)
      redirect_to movie, alert: "Movie info successfully set as blank"
    else
      render :edit
    end
  end

  # Movie Update Method

  def api_call_by_id(id)
    movie_data = []
    url = URI("https://api.themoviedb.org/3/movie/#{id}?api_key=#{ENV["TMDB_API_KEY"]}")
    response = Net::HTTP.get(url)
    movie_json = JSON.parse(response)
    movie_data << movie_json
  end

  # Movie Instance Construction Start

  def crew(id)
    unless id.nil?
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

  # Movie Instance Construction End

  def showings(cinemas)
    result = []
    cinemas.each do |cinema|
      html_content = URI.open(cinema.schedule)
      if cinema.name == "Meguro Cinema"
        utf8_content = html_content.read.encode("UTF-8", "Shift_JIS", invalid: :replace, undef: :replace, replace: "")
        doc = Nokogiri::HTML(utf8_content)
      else
        doc = Nokogiri::HTML.parse(html_content, nil, cinema.encoding)
      end
      result << showing_scrape(doc, cinema)
    end
    result
  end

  def showing_scrape(html, cinema)
    search_results = []
    case cinema.name
    when "Meguro Cinema"
      content = URI.open(Cinema.find_by(name: "Meguro Cinema").schedule).read
      utf8_content = content.encode("UTF-8", "Shift_JIS", invalid: :replace, undef: :replace, replace: "")
      html = Nokogiri::HTML(utf8_content)
      search_results << [meg_showings(html), cinema]
    when "Shimo-Takaido Cinema"
      search_results << [shimo_showings(html), cinema]
    when "Waseda Shochiku"
      search_results << [shochiku_showings(html), cinema]
    when "Shin-Bungeiza"
      search_results << [bungeiza_showings(html), cinema]
    when "Kichijoji Up Link"
      search_results << [kjo_showings(html), cinema]
    end
    search_results
  end

  def showing_create(array, all_movies)
    array.each do |cinema|
      cinema.each do |info|
        place = info[1]
        info[0].each do |date|
          movie = all_movies.find { |film| film.web_title.any? { |title| title.include?(date[:name]) } }
          # movie = Movie.all.find { |film| film.web_title.include?(date[:name]) }
          if movie
            showing = Showing.new(date: date[:date], times: date[:times], movie_id: movie.id, cinema_id: place.id)
            showing.save
          end
        end
      end
    end
  end

  # Kichijoji

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

  # Meguro

  def meg_dates(date_string)
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

  def meg_showings(doc)
    result = []
    doc.search("#timetable").each do |line|
      dates = meg_dates(line.css("p").text)
      line.css(".time_box tr").each do |row|
        title = row.css(".time_title").text.strip
        times = row.css(".time_type2").map { |el| el.text.strip }
        times.each do |time|
          start_time = time.match(/(0?[0-9]|1[0-9]|2[0-3]):[0-5][0-9]/)
          if start_time && dates.size.positive?
            dates.each do |date|
              title = clean_titles([title])[0]
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

  # Waseda Shochiku

  def sho_dates(string)
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

    if string.include?("～") && dates[1]
      date_range = (dates[0]..dates[1])
      dates = date_range.to_a
    end

    dates
  end

  def shochiku_showings(doc)
    result = []
    doc.search(".top-schedule-area").each do |table|
      date_text = table.search('th[colspan="4"]').text
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

  # Shimo-Takaido

  def shimo_dates(string, month)
    dates = []
    integers = string.scan(/(\d+)\([^)]+\)/).flatten.map(&:to_i)
    integers.each_with_index do |day, index|
      month += 1 if day < integers[index - 1] && index.positive?
      dates << Date.new(Date.today.year, month, day) unless day.zero? || month.zero?
      month -= 1 if day < integers[index - 1] && index.positive?
    end
    if string.include?("～") || string.include?("〜")
      dates = (dates.first..dates.last).to_a if dates.size > 1
    end
    dates
  end

  def shimo_showings(doc)
    results = []
    final_array = []
    doc.search(".box").each do |box|
      hash = {}
      title = box.search(".eiga-title").first.text.strip unless box.search(".eiga-title").first.nil?
      clean_title = clean_titles([title])[0] if title
      date_cell = box.search(".day").first.text.strip.gsub("～(", " (")
      if date_cell.include?("\n")
        date_cell.split("\n").each do |day|
          time = day.match(/\d{1,2}：\d{2}|\d{1,2}:\d{2}/)&.[](0)
          if time
            day.split("、").each_with_index do |part, index|
              month = day.split("/").first.to_i
              next if month.nil? || month > 12

              new_hash = {}
              new_hash[:name] = clean_title
              new_hash[:date] = shimo_dates(part, month)
              new_hash[:times] = [time.gsub("：", ":")]
              results << new_hash if hash[:name]
            end
          end
        end
      else
        time = box.search(".day").first.text.strip.match(/\d{1,2}：\d{2}|\d{1,2}:\d{2}/)&.[](0)
        new_time = time.gsub("：", ":") unless time.nil?
        date_cell.split("、").each_with_index do |part, index|
          month = date_cell.split("/").first.to_i
          next if month.nil? || month > 12

          hash = {}
          hash[:name] = clean_title
          hash[:date] = shimo_dates(part, month) if date_cell && hash[:name]
          hash[:times] = [new_time]
          results << hash if hash[:name]
        end
      end
    end
    results.each do |movie|
      movie[:date].each do |date|
        hash = {}
        hash[:name] = movie[:name]
        hash[:date] = date
        hash[:times] = movie[:times]
        final_array << hash
      end
    end
    final_array
  end

  # Shin-Bungeiza

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
end
