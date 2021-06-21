Encoding.default_external = Encoding::UTF_8

require 'rubygems'
require 'bundler'

Bundler.require
require './app.rb'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end

run Sinatra::Application
