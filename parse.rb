require "date"
require "nokogiri"
require "pp"
require "sanitize"

#output = File.open("articles.txt", "w")
articles = []
authors = []
@file = File.open("articoli.xml")
@doc = Nokogiri::XML(@file)

@doc.xpath("/pma_xml_export/table[@name='wp_users']").each do |auth|
  author = {}

  wp_id = auth.xpath("column[@name='ID']").text
  name = auth.xpath("column[@name='user_login']").text

  author[:wp_id] = wp_id
  author[:name] = name

  authors << author
end

pp "Totali autori: ", authors.count

@doc.xpath("/pma_xml_export/table[@name='wp_posts']").each do |post|
  article = {}

  date_text = post.xpath("column[@name='post_date']").text
  #date_text = date_text[0, 10]
  date_format = "%Y-%m-%d %H:%M:%S"
  date = DateTime.strptime(date_text, date_format)
  title = post.xpath("column[@name='post_title']").text
  content = post.xpath("column[@name='post_content']").text
  author = post.xpath("column[@name='post_author']").text

  article[:title] = title
  article[:date] = date
  article[:content] = content
  article[:author_id] = author
  #article[:content] = Sanitize.fragment(content, elements: ['a'], attributes: {a: ['href']})

  articles << article
end

articles.each do |article|
  authors.each do |author|
    if article[:author_id] == author[:wp_id]
      article[:author_name] = author[:name]
    end
  end
end

pp "Totale articoli: ", articles.count

articles.uniq! { |article| article[:content] }

pp "Totale articoli unici: ", articles.count

articles.sort_by { |article| article[:date] }
