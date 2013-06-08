require 'pp'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/url_for'
require 'haml'
require 'coffee-script'
require './db'
# require './groonga'

TWEET_LIMIT = 50

Tilt::CoffeeScriptTemplate.default_bare = true

get '/js/:filename' do
  content_type :js
  coffee :"#{params[:filename]}"
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

  table_name = 'Tweets'
  sort_key = 'created_at'

  if query.empty?
    @tweets = Tweet.desc(:id_str).limit(TWEET_LIMIT)
  else
=begin
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
    tweets = GroongaDB.instance[table_name]
      .select {|e| e.text =~ query}
      .sort([[sort_key, :desc]], offset: 0, limit: TWEET_LIMIT)

    @tweets = []
    i = 0
    tweets.each do |e|
      tweet = Tweet.find(e.status_id)

      tweet.text = snippet.execute(e[".text"]).join

      @tweets << tweet

      i += 1
      break if i >= TWEET_LIMIT
    end
=end
  end

  content_type :js
  CoffeeScript.compile erb(:"search_tweet.js.coffee"), { no_wrap: true }
end
