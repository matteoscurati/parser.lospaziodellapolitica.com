require "date"
require "nokogiri"
require "pp"
require "sanitize"

#output = File.open("output.txt", "w")
articles = []
@file = File.open("articoli.xml")
@doc = Nokogiri::XML(@file)
@doc.xpath("/pma_xml_export/table[@name='wp_posts']").each do |post|
  article = {}

  date_text = post.xpath("column[@name='post_date']").text
  date_text = date_text[0, 10]
  date_format = "%Y-%m-%d"
  date = Date.strptime(date_text, date_format)
  title = post.xpath("column[@name='post_title']").text
  content = post.xpath("column[@name='post_content']").text

  article[:title] = title
  article[:date] = date
  article[:content] = Sanitize.fragment(content, elements: ['a'], attributes: {a: ['href']})

  articles << article
end

pp articles
