module DateHelper
  def formatted_date(date)
    date.strftime("%A, %B #{date.day}#{day_suffix(date.day)}")
  end

  private

  def day_suffix(day)
    if (11..13).include?(day % 100)
      "th"
    else
      case day % 10
      when 1
        "st"
      when 2
        "nd"
      when 3
        "rd"
      else
        "th"
      end
    end
  end
end
