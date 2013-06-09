require 'pp'
require 'pry'
require 'pry-nav'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/url_for'
require 'haml'
require 'coffee-script'
require './db'
require './groonga'

TWEET_LIMIT = 50
API_TWEET_LIMIT = 500

set :views, File.dirname(__FILE__) + "/views"
set :public_folder, File.dirname(__FILE__) + "/public"
Tilt::CoffeeScriptTemplate.default_bare = true

get '/js/:filename' do
  content_type :js
  CoffeeScript.compile erb(:"#{params[:filename]}.coffee"), { no_wrap: true }
end

get '/' do
  @tweets = Tweet.where(:created_at.ne => nil).desc(:status_id).limit(TWEET_LIMIT)
  haml :index
end

get '/stats' do
  @last_update = Tweet.desc(:created_at).first.created_at
  @tweet_count = Tweet.count()

  haml :stats
end

get '/search_tweet' do
  query = params[:q]

  if query.empty?
    @tweets = Tweet.where(:created_at.ne => nil).desc(:status_id).limit(TWEET_LIMIT)
  else
    # インスタンスの作成(初回のみ)
    GroongaDB.instance

    # キーワードを囲むタグ
    open_tag = "<span class=\"keyword\">"
    close_tag = "</span>"
    # スニペットオブジェクトの作成
    snippet = GroongaDB.instance.snippet(:width => 99999,
      :default_open_tag => open_tag,
      :default_close_tag => close_tag,
      # :html_escape => true,
      :skip_leading_spaces => true,
      :normalize => true) # キーワードを正規化
    # 検索キーワードを登録
    snippet.add_keyword(query)

    # @todo escape query
    tweets = GroongaDB.instance['Tweets']
      .select {|e| e.text =~ query}
      .sort([['created_at', :desc]], offset: 0, limit: TWEET_LIMIT)

    @tweets = []
    i = 0
    tweets.each do |e|
      tweet = Tweet.where(status_id: e.status_id).first

      tweet.text = snippet.execute(e[".text"]).join

      @tweets << tweet

      i += 1
      break if i >= TWEET_LIMIT
    end
  end

  content_type :js
  CoffeeScript.compile erb(:"search_tweet.js.coffee"), { no_wrap: true }
end

get '/api/search' do
  # @todo check api key
  query = params[:q]

  # @todo escape query
  tweets = GroongaDB.instance['Tweets']
    .select {|e| e.text =~ query}
    .sort([['created_at', :asc]], offset: 0, limit: API_TWEET_LIMIT)

  content_type :json
  tweets.map{|e|
    {
      'status_id' => e.status_id,
      'text' => e.text,
      'created_at' => e.created_at,
    }
  }.to_json
end
