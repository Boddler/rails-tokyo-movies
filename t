[1mdiff --git a/app/controllers/movies_controller.rb b/app/controllers/movies_controller.rb[m
[1mindex 959c338..b774ac9 100644[m
[1m--- a/app/controllers/movies_controller.rb[m
[1m+++ b/app/controllers/movies_controller.rb[m
[36m@@ -25,15 +25,11 @@[m [mclass MoviesController < ApplicationController[m
     hash = {}[m
     hash[:placeholder] = [@movie.web_title][m
     results = [[[first_api_call(hash)[0][0].select { |element| element["id"] == new_movie_id }.first, @movie.web_title]]][m
[31m-    if results[0][0][0].nil?[m
[31m-      results = [[api_call_by_id(new_movie_id), @movie.web_title]][m
[31m-    end[m
[31m-[m
[32m+[m[32m    results = [[api_call_by_id(new_movie_id), @movie.web_title]] if results[0][0][0].nil?[m
     movie_hash = group_call(results)[0][m
     movie_hash.delete(:id)[m
     movie_hash[:web_title] = @movie.web_title[m
     movie_hash[:poster] = "https://image.tmdb.org/t/p/w500/#{movie_hash[:poster]}"[m
[31m-    # raise[m
     if @movie.update(movie_hash)[m
       redirect_to @movie, notice: "Movie was successfully updated."[m
     else[m
[1mdiff --git a/app/helpers/update_helper.rb b/app/helpers/update_helper.rb[m
[1mindex 31d6aae..17357ba 100644[m
[1m--- a/app/helpers/update_helper.rb[m
[1m+++ b/app/helpers/update_helper.rb[m
[36m@@ -72,6 +72,7 @@[m [mmodule UpdateHelper[m
 [m
   def group_call(results)[m
     languages = JSON.parse(ENV["LANGUAGES"])[m
[32m+[m[32m    unknown = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Question_mark_alternate.svg/1577px-Question_mark_alternate.svg.png"[m
     models_to_be_saved = [][m
     results.each do |movie|[m
       if movie.nil? || !movie[0].empty?[m
[36m@@ -79,7 +80,8 @@[m [mmodule UpdateHelper[m
         hash[:name] = movie[0][0]["title"][m
         hash[:description] = movie[0][0]["overview"][m
         hash[:language] = languages.fetch(movie[0][0]["original_language"], movie[0][0]["original_language"])[m
[31m-        hash[:poster] = movie[0][0]["poster_path"][m
[32m+[m[32m        poster = movie[0][0]["poster_path"][m
[32m+[m[32m        hash[:poster] = poster.nil? ? unknown : "https://image.tmdb.org/t/p/w500/#{poster}"[m
         hash[:year] = movie[0][0]["release_date"][m
         hash[:id] = movie[0][0]["id"][m
         hash[:popularity] = movie[0][0]["popularity"][m
[36m@@ -97,8 +99,10 @@[m [mmodule UpdateHelper[m
 [m
   def movies_create(info)[m
     info.each do |movie|[m
[31m-      new_movie = Movie.new(director: movie[:director], popularity: movie[:popularity], runtime: movie[:runtime], name: movie[:name], description: movie[:description],[m
[31m-                            web_title: movie[:web_title], year: movie[:year], cast: movie[:cast], language: movie[:language], poster: "https://image.tmdb.org/t/p/w500/#{movie[:poster]}",[m
[32m+[m[32m      new_movie = Movie.new(director: movie[:director], popularity: movie[:popularity], runtime: movie[:runtime],[m
[32m+[m[32m                            name: movie[:name], description: movie[:description],[m
[32m+[m[32m                            web_title: movie[:web_title], year: movie[:year], cast: movie[:cast],[m
[32m+[m[32m                            language: movie[:language], poster: movie[:poster],[m
                             backgrounds: movie[:backgrounds])[m
       new_movie.save[m
     end[m
[1mdiff --git a/known_issues.txt b/known_issues.txt[m
[1mindex 3fdac4c..6f64f39 100644[m
[1m--- a/known_issues.txt[m
[1m+++ b/known_issues.txt[m
[36m@@ -1,27 +1,19 @@[m
 Only one director is found (some movies have 2+ directors...)[m
[31m-If numerous movies share a title it might find the wrong one[m
[31m-[m
[31m-[m
 [m
 To Do[m
 Save unfound movies and allow for online updating[m
[32m+[m[32m Need a poster[m
[32m+[m[32mLanding page changes[m
[32m+[m[32m  Add some picks sections[m
[32m+[m[32m    Language?[m
[32m+[m[32m    Director?[m
 navbar options[m
[31m-FAQ[m
 footer fleshing out? - after other things?[m
 movie index[m
 cinema index[m
 cinema show - add modals for the movie info[m
 filter - add cinemas & languages[m
 [m
[31m-Issues[m
[31m-Non known[m
[31m-[m
[31m-[m
[31m-Cinema Specific (needs to be, not yet)[m
[31m-- scrape cinema page[m
[31m-- send titles to movie api call method, which saves the movies[m
[31m-[m
[31m-[m
 [m
 [m
 [m
[1mdiff --git a/new_cinema.rb b/new_cinema.rb[m
[1mindex c345c5a..f0fc3be 100644[m
[1m--- a/new_cinema.rb[m
[1m+++ b/new_cinema.rb[m
[36m@@ -75,13 +75,7 @@[m [mchecking = [][m
 [m
 p_element = html.search(".schedule-program p")[m
 titles = p_element.children.select { |node| node.text? }.map(&:text).reject { |str| str.strip == "" }[m
[31m-[m
[31m-# titles = titles.reject(&:empty?)[m
[31m-# titles = titles.reject { |str| str.strip == "" }[m
[31m-[m
[31m-# html.search(".schedule-program p").each do |element|[m
[31m-#   checking << element.text.match(/^[^（\(]+/)[0].strip[m
[31m-# end[m
[32m+[m[32mp titles[m
 [m
 def movie_api_call(list)[m
   api_key = ENV["TMDB_API_KEY"][m
[36m@@ -99,8 +93,9 @@[m [mdef movie_api_call(list)[m
     if movie_data.any?[m
       title = movie_data[0]["title"][m
       overview = movie_data[0]["overview"][m
[31m-      # language = movie_data.spoken_languages[0][m
[31m-      poster = movie_data[0]["poster_path"][m
[32m+[m[32m      # language = movie_data[0].spoken_languages[0][m
[32m+[m[32m      poster = movie_data[0]["poster_path"] # unless movie_data[0]["poster_path"].nil?[m
[32m+[m[32m      puts "#{title} has no poster path!******************" if movie_data[0]["poster_path"].nil?[m
       language = languages.fetch(movie_data[0]["original_language"], movie_data[0]["original_language"])[m
       year = movie_data[0]["release_date"][m
       id = movie_data[0]["id"][m
[36m@@ -125,47 +120,19 @@[m [mdef movie_api_call(list)[m
       background_data = JSON.parse(background_response)[m
       # background = (background_data["backdrops"][0].nil? ? "https://www.themoviedb.org/t/p/original/bm2pU9rfFOhuHrzMciV6NlfcSeO.jpg" : background_data["backdrops"][0])[m
       background = (background_data["backdrops"].nil? ? nil : background_data["backdrops"])[m
[31m-      # puts "#{title} found successfully"[m
[32m+[m[32m      puts "#{title} found successfully"[m
     else[m
[31m-      puts "Movie not found: #{scraped_title}"[m
[32m+[m[32m      puts "Movie not found: #{scraped_title} ***********************************************"[m
     end[m
   }[m
 end[m
 [m
[31m-# movie_api_call(checking)[m
[32m+[m[32mmovie_api_call(titles)[m
 cleaned_titles = clean_titles(titles).uniq[m
 bleached_titles = cleaned_titles[m
 [m
[31m-# end[m
[31m-[m
[31m-# pp bleached_titles.uniq.sort[m
[31m-# pp cleaned_titles.uniq.size[m
[31m-[m
[31m-# pp titles.size[m
[31m-[m
[31m-pp movie_api_call(bleached_titles)[m
[31m-pp movie_api_call(bleached_titles).size[m
[32m+[m[32m# pp movie_api_call(bleached_titles)[m
[32m+[m[32m# pp movie_api_call(bleached_titles).size[m
 pp bleached_titles.size[m
 [m
 # pp checking.drop(5).take(5)[m
[31m-[m
[31m-# html.search(".schedule-txt-catch").each do |element|[m
[31m-#   unless element.search(".day").first.nil?[m
[31m-#     if element.search(".day").first.text.strip.include?("\n")[m
[31m-#       element.search(".day").first.text.strip.split("\n").each do |snippet|[m
[31m-#         hash = {}[m
[31m-#         hash[:date] = shimo_dates(snippet)[m
[31m-#         hash[:title] = snippet.search(".eiga-title").first.text.strip unless element.search(".eiga-title").first.nil?[m
[31m-#         hash[:time] = snippet.first.text.strip.match(/\d{1,2}：\d{2}/)[m
[31m-#         checking << hash[m
[31m-#       end[m
[31m-#     else[m
[31m-#       hash = {}[m
[31m-#       hash[:title] = element.search(".eiga-title").first.text.strip unless element.search(".eiga-title").first.nil?[m
[31m-#       time = element.search(".day").first.text.strip.match(/\d{1,2}：\d{2}/)[m
[31m-#       hash[:times] = time[0] if time[m
[31m-#       hash[:date] = element.search(".day").first.text.strip # unless element.search(".eiga-title").first.text.strip.nil?[m
[31m-#       checking << hash[m
[31m-#     end[m
[31m-#   end[m
[31m-# end[m
