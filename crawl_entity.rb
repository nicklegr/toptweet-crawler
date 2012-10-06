#!/usr/bin/ruby

require 'twitter'
require 'pp'
require './db'

yaml = YAML.load_file("config.yaml")

Twitter.configure do |config|
  config.consumer_key = yaml['consumer_key']
  config.consumer_secret = yaml['consumer_secret']
  config.oauth_token = yaml['oauth_token']
  config.oauth_token_secret = yaml['oauth_token_secret']
end
# pp Twitter.rate_limit_status.remaining_hits

Tweet.where(:created_at.exists => false).each do |tweet|
  id = tweet.status_id
# pp id

  begin
    status = Twitter.status(id)
# pp status

    tweet.update_attributes!(
      # status_id: status.id,
      text: status.text,
      user_id: status.user.id,
      screen_name: status.user.screen_name,
      retweet_count: status.retweet_count,
      created_at: status.created_at,
    )

    sleep 0.5
  rescue Twitter::Error::NotFound, Twitter::Error::Forbidden => e
    # �폜�ς� or ���A�J
    tweet.delete
  rescue Twitter::Error::BadRequest => e
    pp e

    # rate limit�Ȃ炠����߂�
    if e.to_s.match("Rate limit")
      puts "rate limit exceeded"
      exit
    end
  rescue => e
    pp e

    # �Ȃ񂾂낤
    # @todo Over capacity�Ή�
  end
end
