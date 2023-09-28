date_string = "9月24日(日) ・ 9月27日(火)"

# Extract start and end dates using regular expressions
matches = date_string.scan(/(\d{1,2})月(\d{1,2})日\(.+?\)/)

# Generate an array of formatted dates
date_range = (matches[0][1].to_i..matches[1][1].to_i).map { |day| "#{matches[0][0]}月#{day}日(#{matches[0][2]})" }

p date_range
