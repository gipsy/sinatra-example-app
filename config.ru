use Rack::Static,
  :urls => ['/stylesheets', '/images'],
  :root => 'public/compiled'

require 'bundler'

Bundler.require

require './application'

run Application

