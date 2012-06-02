#!/usr/bin/ruby

require './favstar'
require './favotter'
require './db'

tweet_ids = []

tweet_ids += Favstar.get
tweet_ids += Favotter.get
# pp tweet_ids.size

tweet_ids.sort!
tweet_ids.uniq!
# pp tweet_ids.size

tweet_ids.each do |id|
  Tweet.find_or_initialize_by(status_id: id) do |record|
    if record.new?
      record.status_id = id
      record.save!
    end
  end
end
