require "rubygems"
require "nokogiri"
require "open-uri"

@url = "https://hackerone.com"

def load_page(page)
  begin
    sleep(1)
    @page = Nokogiri::HTML(open(page))
    puts "Loaded #{page}"
  rescue SocketError => se
    puts "Socket Error: #{se}. Ending Script."
    exit
  end
  
  if next_item = @page.css('a[rel="next"]')
    @next_url = "#{@url}#{next_item.first["href"]}"
  else
    @next_url = nil
  end
end

file = open("hackerone_reports", "a+")
begin
  last_report = file.readline.match(/reports\/(\d+)/)[1].to_i
rescue EOFError
  last_report = 0
end

load_page("#{@url}/hacktivity")
count = 0

while @next_url
  @page.css("a").each do |link|
    report = link["href"].match(/reports\/(\d+)/)[1].to_i if link["href"].match(/reports\/(\d+)/)
    if report
      if report > last_report
        file.write("#{@url}#{link['href']},#{link.text}\n")
        count += 1
      elsif report <= last_report
        file.close
        p "Last report was #{last_report}, current report is #{report}. Exiting after adding #{count} new reports"
        exit
      end
    end
  end

  load_page(@next_url)
end

