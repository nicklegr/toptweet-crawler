#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'pp'

class Favotter
  BASE_URL = 'http://favotter.net/home.php?mode=best'
  MIN_FAV = 30
  MAX_PAGE = 10

  def self.get
    tweet_ids = []

    # 指定fav以上をすべて取得できるまでページを送る
    (1..MAX_PAGE).each do |i|
      url = BASE_URL
      url += "&page=#{i}" if i >= 2

      doc = Nokogiri::HTML(open(url))

      doc.css('div[id^="status_"]').each do |div|
        raise if !div.css('span.favotters').text.match(/(\d+) favs by/)

        fav_count = $1.to_i
        if fav_count < MIN_FAV
          return tweet_ids
        end

        div.css('a.taggedlink[href]').each do |a|
          link = a['href']
          if link.match(%r|twitter\.com(?:.*)/(?:\w+)/status(?:es)?/(\d+)|)
            tweet_ids << $1.to_i
          end
        end
      end
    end
    
    tweet_ids
  end
end
