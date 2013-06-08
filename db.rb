#!ruby -Ku

require 'mongoid'

class Tweet
  include Mongoid::Document

  field :status_id, type: Integer
  field :text, type: String

  field :user_id, type: Integer
  field :screen_name, type: String
  
  field :retweet_count, type: Integer
  field :fav_count, type: Integer

  field :created_at, type: Time # Twitterから取得した時刻。not レコード作成時刻

  validates_uniqueness_of :status_id
end

# add index as follows:
#   db.tweets.ensureIndex({status_id:1},{unique:true});

Mongoid.configure do |conf|
  conf.master = Mongo::Connection.new.db('toptweets')
end
