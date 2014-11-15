require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'data_mapper'
require 'rack/parser'

class Drink
  include DataMapper::Resource
  property :id, 	Serial
  property :name,   String

  has n, :ingredients
end

class Ingredient
  include DataMapper::Resource
  property :id,     Serial
  property :type,   String
  property :amount, Integer

  belongs_to :drink
end

configure do  
  DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/development.sqlite3"))
  DataMapper.auto_upgrade!
  enable :cross_origin
end

use Rack::Parser, :content_types => {
  'application/json'  => Proc.new { |body| ::MultiJson.decode body }
}

helpers do
  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  def drink_to_json(drink)
    {
      name: drink.name,
      _embedded: {
        ingredients: drink.ingredients.map { |i| { type: i.type, amount: i.amount } }
      },
      _links: {
        'self' => base_url + '/drinks/' + drink.id.to_s
      }
    }.to_json
  end

end

get '/' do  
  content_type :json
  { 
    message: 'Hello World. Would you like a cocktail?',
    _links: {
      'self' => base_url,
      'drinks' => base_url + '/drinks'
    }
  }.to_json
end

get '/drinks' do
  content_type :json  

  { 
    _embedded: { drinks: Drink.all }, 
    _links: { 'self' => base_url + '/drinks' } 
  }.to_json
end

get '/drinks/:id' do
  content_type :json
  drink = Drink.get(params[:id])
  drink_to_json(drink)
end

post '/drinks' do
  content_type :json
  
  drink = Drink.create( name: params[:name] )
  (params[:ingredients] || []).each do |ingredient| 
    drink.ingredients.create(ingredient) 
  end  
  
  drink_to_json(drink)
end