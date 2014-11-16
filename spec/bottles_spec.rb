require 'spec_helper'
require_relative '../cocktail_api'

describe 'Bottles' do
	include Rack::Test::Methods

  	def app
    	Sinatra::Application.new
  	end

	describe "GET /bottles" do
	  let(:response_data) { JSON.parse(response.body) }
	  let(:response) { 
	  	get '/bottles' 
	  	last_response
	  }

	  it 'should be successful' do
	  	expect(response).to be_ok
	  end

	  it 'should be a json response' do
			expect(response.content_type).to eq('application/json')
	  end

	  it 'should have a self link' do
			expect(response_data['_links']['self']).to eq('http://example.org/bottles')
	  end

	  context 'when there are no bottles' do
	  	it 'should return an empty list of bottles' do
	  		expect(response_data['_embedded']['bottles']).to eq []
	  	end
	  end
	  
	  context 'when a drinks exists' do
	  	before do
	  		Bottle.create(type: 'Vodka', amount: 700, pin: 1)
	  		Bottle.create(type: 'Gin', amount: 700, pin: 2)
	  	end

	  	it 'should return a list of bottles' do
	  		expect(response_data['_embedded']['bottles'].length).to eq 2
	  	end

	  	describe 'bottle' do
	  		let(:bottle) { response_data['_embedded']['bottles'].first }

	  		it 'should include the bottles type' do		  		
		  		expect(bottle['type']).to eq 'Vodka'
		  	end

		  	it 'should include a self link' do		  		
		  		expect(bottle['_links']['self']).to eq 'http://example.org/bottles/1'
		  	end
		  end
	  end

	end

	describe "POST /bottles" do
		let(:response) { 
			data = { type: 'Gin', amount: 700, pin: 1 }
	  	post '/bottles', data.to_json, "CONTENT_TYPE" => "application/json" 
	  	last_response
	  }
	  let(:response_data) { JSON.parse(response.body) }

		it "should be successful" do
			expect(response).to be_ok	
		end

		it 'should be a json response' do
			expect(response.content_type).to eq 'application/json'
	  end

	  it 'should return the type of the bottle' do
			expect(response_data['type']).to eq 'Gin'
	  end

	  it 'should return the amount left in the bottle' do
			expect(response_data['amount']).to eq 700
	  end		

		it 'should return the pin the bottle is attached to' do
			expect(response_data['pin']).to eq 1
	  end		

	  it 'should have a self link' do
			expect(response_data['_links']['self']).to eq 'http://example.org/bottles/1'
	  end

	end
	
	describe "GET /bottle/:id" do
	
		before do
			@bottle = Bottle.create(type: 'Gin', amount: 700, pin: 1 )
		end

		let(:response) { 
  		get "/bottles/#{@bottle.id}"
  		last_response
	  }
	  let(:response_data) { JSON.parse(response.body) }

		it "should be successful" do
			expect(response).to be_ok	
		end

		it 'should be a json response' do
			expect(response.content_type).to eq 'application/json'
  	end  

  	describe "bottle" do
  		subject { response_data }
  		it "should have a name" do
  			expect(subject['type']).to eq 'Gin'
  		end
  		it "should have an amount" do
  			expect(subject['amount']).to eq 700
  		end
  		it "should have a pin" do
  			expect(subject['pin']).to eq 1
  		end
  	end

	end

	describe "PATCH /bottles/:id" do
		before do
			@bottle = Bottle.create(type: 'Vodka', amount: 700)
		end
		let(:response) { 
			data = { 
				amount: 670
			}
	  	patch "/bottles/#{@bottle.id}", data.to_json, "CONTENT_TYPE" => "application/json" 
	  	last_response
	  }
	  let(:response_data) { JSON.parse(response.body) }

		it "should be successful" do
			expect(response).to be_ok	
		end

		it 'should be a json response' do
			expect(response.content_type).to eq 'application/json'
	  end

		it 'should update the drink' do
			response
			expect(Bottle.first.amount).to eq 670
	  end

	  it 'should return the details of the drink' do
			expect(response_data['type']).to eq 'Vodka'
	  end

	  it 'should have a self link' do
			expect(response_data['_links']['self']).to eq 'http://example.org/bottles/1'
	  end	
	end

	describe "DELETE /bottle/:id" do
	  before do
	  	@bottle = Bottle.create(type: 'Gin', amount: 700)
	  end

		let(:response) { 		
	  	delete "/bottles/#{@bottle.id}"
	  	last_response
	  }

	  it "should be successful" do
			expect(response).to be_ok	
		end

		it 'should be a json response' do
			expect(response.content_type).to eq 'application/json'
	  end

	  it 'should delete the bottle' do
	  	response
			expect(Bottle.all.length).to eq 0
	  end
	end
end