require 'spec_helper'
require_relative '../cocktail_api'

describe 'Cocktail API' do
	include Rack::Test::Methods

  	def app
    	Sinatra::Application.new
  	end

	describe 'root path' do 
		let(:response) { 
	  	get '/'
	  	last_response
	  }
	  let(:response_data) { JSON.parse(response.body) }

		it 'should be successful' do
			expect(response).to be_ok
		end

		it 'should be a json response' do
			expect(response.content_type).to eq('application/json')
		end

		it 'should return a hello world message' do
			expect(response_data['message']).to eq('Hello World. Would you like a cocktail?')
		end	

		it 'should have a self link' do
			expect(response_data['_links']['self']).to eq 'http://example.org'
		end

		it 'should have a drinks link' do
			expect(response_data['_links']['drinks']).to eq 'http://example.org/drinks'
		end
	end

	describe "GET /drinks" do
	  let(:response_data) { JSON.parse(response.body) }
	  let(:response) { 
	  	get '/drinks' 
	  	last_response
	  }

	  it 'should be successful' do
	  	expect(response).to be_ok
	  end

	  it 'should be a json response' do
			expect(response.content_type).to eq('application/json')
	  end

	  it 'should have a self link' do
			expect(response_data['_links']['self']).to eq('http://example.org/drinks')
	  end

	  context 'when there are no drinks' do
	  	it 'should return an emtty list of drinks' do
	  		expect(response_data['_embedded']['drinks']).to eq []
	  	end
	  end
	  
	  context 'when a drinks exists' do
	  	before do
	  		Drink.create(name: 'Bloody Mary')
	  	end

	  	it 'should return an empty list of drinks' do
	  		expect(response_data['_embedded']['drinks'].length).to eq 1
	  	end
	  end

	end

	describe "POST /drinks" do
		let(:response) { 
			data = { name: 'Gin and Juice', ingredients: [ { type: 'Gin', amount: 30 }, { type: 'Juice', amount: 100 } ] }
	  	post '/drinks', data.to_json, "CONTENT_TYPE" => "application/json" 
	  	last_response
	  }
	  let(:response_data) { JSON.parse(response.body) }

		it "should be successful" do
			expect(response).to be_ok	
		end

		it 'should be a json response' do
			expect(response.content_type).to eq 'application/json'
	  end

	  it 'should return the details of the drink' do
			expect(response_data['name']).to eq 'Gin and Juice'
	  end

		it 'should return the ingredients of the drink' do
			expect(response_data['_embedded']['ingredients'].length).to eq 2
			expect(response_data['_embedded']['ingredients'].first).to eq( { 'type' => 'Gin', 'amount' => 30 } )
			expect(response_data['_embedded']['ingredients'].last).to eq( { 'type' => 'Juice', 'amount' => 100 } )
	  end

	  it 'should have a self link' do
			expect(response_data['_links']['self']).to eq 'http://example.org/drinks/1'
	  end

	end
	
	describe "GET /drink/:id" do
	
		before do
			@drink = Drink.create(name: 'Gin and Juice')
			@drink.ingredients.create( type: 'Gin', amount: 30)
			@drink.ingredients.create( type: 'Juice', amount: 100)
		end
		let(:response) { 
	  	get "/drinks/#{@drink.id}"
	  	last_response
	  }
	  let(:response_data) { JSON.parse(response.body) }

		it "should be successful" do
			expect(response).to be_ok	
		end

		it 'should be a json response' do
			expect(response.content_type).to eq 'application/json'
	  end  

	end
end