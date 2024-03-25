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

z = 12

x = Date.new(2024, z, 28)
y = Date.new(2024, (z + 1), 3)

p x
p (y - x).to_i
