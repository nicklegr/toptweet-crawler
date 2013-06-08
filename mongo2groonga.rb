# coding: utf-8

require 'pp'
require './db'
require './groonga'

count = 0

Tweet.all.each do |tweet|
  tweets = GroongaDB.instance["Tweets"]

  already = tweets.select("status_id:#{tweet.status_id}")

  if already.size == 0
    tweets.add({
      status_id: tweet.status_id,
      text: tweet.text,
      created_at: tweet.created_at,
    })
    count += 1
  end
end

puts "added count: #{count}"
