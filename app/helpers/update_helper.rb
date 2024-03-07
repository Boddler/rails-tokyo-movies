module UpdateHelper
  require "open-uri"
  require "json"
  require "nokogiri"
  require "dotenv/load"

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
      movie_json = JSON.parse(response)
      movie_data << movie_json["results"].sort_by { |movie| -movie["vote_count"].to_f }
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
      title = movie[0]["title"]
      overview = movie[0]["overview"]
      language = languages.fetch(movie[0]["original_language"], movie[0]["original_language"])
      poster = movie[0]["poster_path"]
      year = movie[0]["release_date"]
      id = movie[0]["id"]
      popularity = movie[0]["popularity"]
      people = crew(id)
      cast = people[0]
      director = people[1]
      runtime = runtime(id)
      backgrounds = backgrounds(id)
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
    background_url = URI("https://api.themoviedb.org/3/movie/#{id}/images?api_key=#{api_key}")
    background_response = Net::HTTP.get(background_url)
    background_data = JSON.parse(background_response)
    background_data["backdrops"].nil? ? nil : background_data["backdrops"]
  end
end
