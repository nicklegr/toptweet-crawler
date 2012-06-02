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

  field :created_at, type: Time # Twitter����擾���������Bnot ���R�[�h�쐬����

  validates_uniqueness_of :status_id
end

Mongoid.configure do |conf|
  conf.master = Mongo::Connection.new.db('toptweets')
end
