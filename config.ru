
require 'bundler'
# works with heroku

use Rails::Rack::LogTailer
use Rails::Rack::Static
run ActionController::Dispatcher.new

Bundler.require

require './application'

run Application

