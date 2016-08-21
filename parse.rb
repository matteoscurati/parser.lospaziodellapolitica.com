require "date"
require "nokogiri"
require "pp"
require "sanitize"

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

print "Totali autori: ", authors.count, "\n"
@doc.xpath("/pma_xml_export/table[@name='wp_posts']").each do |post|
  article = {}

  #if ! post.xpath("column[@name='post_title']").text.empty? || post.xpath("column[@name='post_content']").empty?
    date_text = post.xpath("column[@name='post_date']").text
    date_text = date_text[0, 10]
    date_format = "%Y-%m-%d"
    date = Date.strptime(date_text, date_format)
    id = post.xpath("column[@name='ID']").text
    title = post.xpath("column[@name='post_title']").text
    content = post.xpath("column[@name='post_content']").text
    author = post.xpath("column[@name='post_author']").text

    article[:id] = id
    article[:title] = title
    article[:date] = date
    article[:content] = content
    article[:author_id] = author
    #article[:content] = Sanitize.fragment(content, elements: ['a'], attributes: {a: ['href']})

    articles << article
  #end
end

articles.each do |article|
  authors.each do |author|
    if article[:author_id] == author[:wp_id]
      article[:author_name] = author[:name]
    end
  end
end

print "Totale articoli: ", articles.count, "\n"

articles.uniq! { |article| article[:content] }

articles.delete_if { |article| article[:title].empty? }
articles.delete_if { |article| article[:content].empty? }
articles.delete_if { |article| article[:author_id].empty? }

articles = articles.sort_by { |article| article[:id] }.reverse

articles.uniq! { |article| article[:title] }

print "Totale articoli unici: ", articles.count, "\n"

print "Totale articoli validi: ", articles.count, "\n"

articles.each do |art|
  if art[:title] == "Roberto Baggio, la demografia italiana, il nuovo welfare"
    pp art[:id]
  end
end
