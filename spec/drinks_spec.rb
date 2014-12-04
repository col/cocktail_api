require 'spec_helper'
require_relative '../cocktail_api'

describe 'Drinks' do
  include Rack::Test::Methods

    def app
      Sinatra::Application.new
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
      it 'should return an empty list of drinks' do
        expect(response_data['_embedded']['drinks']).to eq []
      end
    end
    
    context 'when a drinks exists' do
      before do
        Drink.create(name: 'Bloody Mary')
        Drink.create(name: 'Gin and Tonic')
      end

      it 'should return a list of drinks' do
        expect(response_data['_embedded']['drinks'].length).to eq 2
      end

      describe 'drink' do
        let(:drink) { response_data['_embedded']['drinks'].first }

        it 'should include the drinks name' do          
          expect(drink['name']).to eq 'Bloody Mary'
        end
        it 'should include a self link' do          
          expect(drink['_links']['self']).to eq 'http://example.org/drinks/1'
        end
      end
    end

  end

  describe "POST /drinks" do
    let(:response) { 
      data = { 
        name: 'Gin and Juice', 
        description: 'Combine gin and tonic and enjoy.', 
        ingredients: [ { type: 'Gin', amount: 30 }, { type: 'Juice', amount: 100 } ] 
      }
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
      expect(response_data['description']).to eq 'Combine gin and tonic and enjoy.'
    end

    it 'should return the ingredients of the drink' do
      expect(response_data['ingredients'].length).to eq 2
      expect(response_data['ingredients'].first).to eq( { 'type' => 'Gin', 'amount' => 30 } )
      expect(response_data['ingredients'].last).to eq( { 'type' => 'Juice', 'amount' => 100 } )
    end

    it 'should have a self link' do
      expect(response_data['_links']['self']).to eq 'http://example.org/drinks/1'
    end

  end

  describe "PATCH /drink/:id" do
    before do
      @drink = Drink.create(name: 'Bloody Mary')
      @drink.ingredients.create( type: 'Vodka', amount: 30)
      @drink.ingredients.create( type: 'Tomato Juice', amount: 100)
    end
    let(:response) { 
      data = { 
        name: 'Bloody Mary 2',
        ingredients: [
          { amount: 60, type: "Gin" }
        ] 
      }
      patch "/drinks/#{@drink.id}", data.to_json, "CONTENT_TYPE" => "application/json" 
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
      expect(Drink.first.name).to eq 'Bloody Mary 2'
    end

    it 'should return the details of the drink' do
      expect(response_data['name']).to eq 'Bloody Mary 2'
    end

    it 'should have a self link' do
      expect(response_data['_links']['self']).to eq 'http://example.org/drinks/1'
    end 

    it 'should update the ingredients' do
      response
      ingredients = Drink.first.ingredients
      expect(ingredients.size).to eq 1
      expect(ingredients.first.amount).to eq 60
      expect(ingredients.first.type).to eq 'Gin'
    end
  end
  
  describe "GET /drink/:id" do
  
    before do
      @drink = Drink.create(name: 'Gin and Juice', description: 'Combine gin and tonic and enjoy.')
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

    describe "drink" do
      subject { response_data }
      it "should have a name" do
        expect(subject['name']).to eq 'Gin and Juice'
      end
      it "should have a description" do
        expect(subject['description']).to eq 'Combine gin and tonic and enjoy.'
      end
      it 'should have ingredients' do
        expect(subject['ingredients'].length).to be 2
        expect(subject['ingredients'].first).to eq( { 'type' => 'Gin', 'amount' => 30 } )
        expect(subject['ingredients'].last).to eq( { 'type' => 'Juice', 'amount' => 100 } )
      end
    end

  end

  describe "DELETE /drink/:id" do
    before do
      @drink = Drink.create(name: 'Gin and Juice', description: 'Combine gin and tonic and enjoy.')
      @drink.ingredients.create( type: 'Gin', amount: 30)
      @drink.ingredients.create( type: 'Juice', amount: 100)
    end

    let(:response) {    
      delete "/drinks/#{@drink.id}"
      last_response
    }

    it "should be successful" do
      expect(response).to be_ok 
    end

    it 'should be a json response' do
      expect(response.content_type).to eq 'application/json'
    end

    it 'should delete the drink' do
      response
      expect(Drink.all.length).to eq 0
    end

    it 'should delete the ingredients' do
      response
      expect(Ingredient.all.length).to eq 0
    end
  end

end