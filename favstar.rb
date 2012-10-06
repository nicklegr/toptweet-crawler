#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'pp'

class Favstar
  URLS = [
    'http://ja.favstar.fm/recent_most_faved/30-favorites',
    'http://ja.favstar.fm/recent_most_faved/50-favorites',
    'http://ja.favstar.fm/recent_most_faved/100-favorites',
  ]

  def self.get
    tweet_ids = []

    URLS.each do |url|
      doc = Nokogiri::HTML(open(url))

      doc.css('a.fs-date[href]').each do |a|
        link = a['href']
        if link.match(%r|/users/\w+?/status/(\d+)|)
          tweet_ids << $1.to_i
        end
      end
    end
    
    tweet_ids
  end
end
