require "date"
# string = "3/19(火)･20(水･祝)･21(木)"

# month_1 = string.split("/").first.to_i
# match_data = string.match(/\/(.+)$/)
# if match_data
#   integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
# end
# integers.reject! { |num| num == 0 }

# p string

# p integers

# z = 12

# x = Date.new(2024, z, 28)
# y = Date.new(2024, (z + 1), 3)

# p x
# p (y - x).to_i

string1 = "3/30(土)～4/5(金)"
string2 = "4/13(土)～4/15(月)"
string3 = "3/19(火)･20(水･祝)･21(木)"

# def shochiku_dates(string)
#   dates = []
#   month = string.split("/").first.to_i
#   match_data = string.match(/\/(.+)$/)
#   if string.include?("～")
#     range = []
#     if match_data
#       integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
#     end
#     integers.each_with_index do |day, index|
#       month += 1 if day < integers[integers.index(day) - 1] && !index.zero?
#       range << Date.new(Date.today.year, month, day) unless day == 0
#       month -= 1 if day < integers[integers.index(day) - 1] && !index.zero?
#     end
#     (range[0]..range[1]).each do |day|
#       dates << day
#     end
#   else
#     if match_data
#       integers = match_data[1].split("･").map { |s| s.split(/(?<!\/)\d+\//).reject(&:empty?) }.flatten.map(&:to_i)
#     end
#     integers.each_with_index do |day, index|
#       month += 1 if day < integers[integers.index(day) - 1] && !index.zero?
#       dates << Date.new(Date.today.year, month, day) unless day == 0
#       month -= 1 if day < integers[integers.index(day) - 1] unless index.zero?
#     end
#   end
#   dates
# end

require "date"

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

  if string.include?("～")
    date_range = (dates[0]..dates[1])
    dates = date_range.to_a
  end

  dates
end

# Example usage
# p dates("4/30(火)～5/3(金)")
#=> [#<Date: 2024-04-30 ((2460412j,0s,0n),+0s,2299161j)>, #<Date: 2024-05-01 ((2460413j,0s,0n),+0s,2299161j)>, #<Date: 2024-05-02 ((2460414j,0s,0n),+0s,2299161j)>, #<Date: 2024-05-03 ((2460415j,0s,0n),+0s,2299161j)>]

p dates(string1)
p dates(string2)
p dates(string3)
