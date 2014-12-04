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

		it 'should have a bottles link' do
			expect(response_data['_links']['bottles']).to eq 'http://example.org/bottles'
		end
	end
	
end