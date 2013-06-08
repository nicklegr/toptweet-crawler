# coding: utf-8

ENABLE_GROONGA =
  begin
    require 'groonga'
    true
  rescue LoadError
    false
  end

require 'singleton'

class Null
  def self.instance
    Null.new
  end

  def method_missing(name, *args)
    self
  end

  def respond_to_missing?(symbol, include_private)
    true
  end
end

class GroongaDBImpl
  include Singleton

  def initialize
    Groonga::Context.default_options = { :encoding => :utf8 }
    open('groonga')
  end

  def [](table_name)
    Groonga::Context.default[table_name]
  end

  def snippet(option)
    Groonga::Snippet.new(option)
  end

  private
  def open(base_path)
    path = File.join(base_path, "toptweets.db")
    if File.exist?(path)
      @database = Groonga::Database.open(path)
    else
      FileUtils.mkdir_p(base_path)
      @database = Groonga::Database.create(:path => path)
      define_schema
    end
  end

  def define_schema  
    Groonga::Schema.define do |schema|
      schema.create_table("Tweets", :type => :array) do |table|  
        table.uint64("status_id")
        table.text("text")
        table.time("created_at")
      end

      schema.create_table("Terms",  
                          :type => :patricia_trie,
                          :normalizer => :NormalizerAuto,
                          :default_tokenizer => "TokenBigram") do |table|  
        table.index("Tweets.status_id")  
        table.index("Tweets.text")  
        table.index("Tweets.created_at")  
      end  
    end
  end
end

GroongaDB = ENABLE_GROONGA ? GroongaDBImpl : Null
