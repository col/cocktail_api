require 'sinatra'
require 'rspec'
require 'rack/test'
require 'data_mapper'
require 'database_cleaner'

ENV['RACK_ENV'] = 'test'

ENV["DATABASE_URL"] = "sqlite3:///#{Dir.pwd}/test.sqlite3"

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner[:data_mapper].strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end

end