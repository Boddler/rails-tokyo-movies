require 'nokogiri'

html = <<-HTML
<div id="timetable_detail">
    <h3 id="show_time">上映時間<!--<font color="red">　★上映スケジュールは、近日発表！--></h3>
    <div class="mgn05"><!-- space --></div>
    <div id="timetable">
        <!-- ↓上映日程↓ -->
        <p><font size="3">9月24日(日)&nbsp;～&nbsp;9月26日(火)</font></p>
        <!-- ↑上映日程↑ -->
        <table class="time_box" cellspacing="0" cellpadding="2">
            <!-- ↓上映時間 ↓-->
            <tr>
                <td class="time_title cell_grey">月光の囁き</td>
                <td class="time_type2 cell_white">11:00<span class="time_end">&nbsp;～&nbsp;終映12:45</span></td>
                <td class="time_type2 cell_grey">14:40<span class="time_end">&nbsp;～&nbsp;終映16:25</span></td>
                <td class="time_type2 cell_white">18:15<span class="time_end">&nbsp;～&nbsp;終映20:00</br></br><font color="blue">※終映後、完全入替</br><font color="green">※ラスト１本割 適用</span></td>
            </tr>
            <tr>
                <td class="time_title cell_grey">どこまでもいこう</td>
                <td class="time_type2 cell_white">13:05<span class="time_end">&nbsp;～&nbsp;終映14:25</span></td>
                <td class="time_type2 cell_grey">16:40<span class="time_end">&nbsp;～&nbsp;終映18:00</span></td>
                <td class="time_type2 cell_white"><span class="time_end"></span></td>
            </tr>
            <tr>
                <td class="time_title cell_grey">さよならくちびる</td>
                <td class="time_type2 cell_white"><span class="time_end"></span></td>
                <td class="time_type2 cell_grey"><span class="time_end"></span></td>
                <td class="time_type2 cell_white"><a target="_blank" href="https://eigaland.com/cinema/143">20:20<span class="time_end">&nbsp;～&nbsp;終映22:20</br></br><font color="red">※オンラインチケット購入は、こちらをクリック</span></td>
            </tr>
            <!--↑上映時間 ↑-->
        </table>
    </div><!-- /timetable-->
    <div id="bikou">
        <!-- ↓備考↓-->
        <span>
            <!--          <font color="green">※『林檎とポラロイド』17:40の回のみご鑑賞の場合は、ラスト1本割1,000円適用です。</br>-->
        </span>
        <!-- ↑備考↑ -->
    </div>
</div>
HTML


doc = Nokogiri::HTML(html)
result = []

# Find the timetable element
timetable = doc.css('#timetable')

# Find the movie titles and their showtimes
timetable.css('.time_box tr').each do |row|
  title = row.css('.time_title').text.strip
  times = row.css('.time_type2').map { |el| el.text.strip }
  start = row.css('#timetable p').text.strip

  times.each do |time|
    # Use regular expression to extract start times
    start_time = time.match(/\d{2}:\d{2}/)

    if start_time
      result << { title => start_time[0], start_date: start }
      p start
    end
  end
end

puts result
