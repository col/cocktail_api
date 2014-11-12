require 'sinatra'
require 'json'

get '/' do
  content_type :json  
  { message: 'Hello World. Who needs a drink?' }.to_json
end