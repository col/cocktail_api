require 'sinatra'
require 'json'
require 'data_mapper'

class Drink
  include DataMapper::Resource
  property :id, 	Serial
  property :name,   String
end

configure do
  DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/development.sqlite3"))    
  DataMapper.auto_upgrade!
end

get '/' do
  content_type :json  
  { message: 'Hello World' }.to_json
end