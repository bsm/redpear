require 'rubygems'
require 'bundler/setup'
Bundler.require :default, :test

require 'rspec'
require 'redpear'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
end
