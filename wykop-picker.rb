require 'nokogiri'
require 'open-uri'

NICK = ''
UPVOTE_PAGE = ''
COMMENT_PAGE = ''

class User
  def initialize(nick, zielonka)
    @nick = nick.delete("\r\n        \\").delete("\t\t")
    @zielonka = zielonka
  end

  def zielonka?
    @zielonka
  end
end

subers = []
page = 0

while true
  page += 1
  url = "http://www.wykop.pl/ludzie/followers/#{NICK}/strona/#{page}"

  sub_page = Nokogiri::HTML(open(url).read)

	users = sub_page.css('.usercard span').select { |user| user.attribute('class').to_s.include?('color-') }

  break if users.empty?

  subers += users.map do |user|
    User.new(user.text, user.attribute('class') == 'color-0')
  end
end

upvoters = []

upvote_page = Nokogiri::HTML(open(UPVOTE_PAGE).read)
upvote_page.css('a').each do |tag|
  zielonka = tag.attributes['color-0'] != nil
  nick = tag.children.first.to_s.delete(', ')

  upvoters << User.new(nick, zielonka)
end


commenters = []
comment_page = Nokogiri::HTML(open(COMMENT_PAGE).read)

commenters = comment_page.css('li .author a.showProfileSummary').map do |tag|
  zielonka = tag.attribute('class').to_s.include?('color-0')
  nick = tag.text
  [nick, zielonka]
end.uniq

commenters.map! { |com| User.new(com.first, com.last) }

commenters.last


pool = []

subers.each do |suber|
  pool << suber
  next if suber.zielonka?
  pool << suber
end

upvoters.each do |upvoter|
  pool << upvoter
  next if upvoter.zielonka?
  pool << upvoter
end

commenters.each do |commenter|
  pool << commenter
  next if commenter.zielonka?
  pool << commenter
end

p pool.sample
p pool.sample


