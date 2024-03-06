module UpdateHelper
  def clean_titles(list)
    list.map! { |str| str.sub(/4K.*/, "") }
    list.map! { |str| str.sub(/デジタルリマスター.*/, "") }
    list.map! { |str| str.sub(/＋.*/, "") }
  end

  def scrape
  end
end
