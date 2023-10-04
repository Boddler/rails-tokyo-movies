# Assuming 'movies' is your array of hashes
movies = [
  { :name => "マイ・プライベート・アイダホ", :time => "10:00", :dates => ["10月18日(Wed)", "10月19日(Thu)"] },
  { :name => "マイ・プライベート・アイダホ", :time => "16:35", :dates => ["10月18日(Wed)", "10月19日(Thu)"] },
  { :name => "マイ・プライベート・アイダホ", :time => "12:15", :dates => ["10月15日(Sun)", "10月16日(Mon)"] },
  { :name => "マイ・プライベート・アイダホ", :time => "18:20", :dates => ["10月15日(Sun)", "10月16日(Mon)"] },
]

# Create a new hash to store the grouped showtimes
grouped_movies = {}

# Iterate through each movie hash and group the showtimes by date
movies.each do |movie|
  movie[:dates].each do |date|
    date_key = date.match(/\d{1,2}月\d{1,2}日/)[0] # Extract the date key

    if grouped_movies[date_key]
      grouped_movies[date_key][:time] << movie[:time]
    else
      grouped_movies[date_key] = { name: movie[:name], time: [movie[:time]], date: date_key }
    end
  end
end

# Convert the values of the hash back to an array of hashes
grouped_movies = grouped_movies.values

puts grouped_movies
