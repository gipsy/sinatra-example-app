# Libraries::::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'sinatra/base'
require 'sinatra/flash'
require 'rack/csrf'
require 'sprockets'
require 'nokogiri'
require 'open-uri'
require 'slim'
require 'sass'
require 'coffee-script'
require 'compass'
require './app/helpers/assets_helpers'


# Application::::::::::::::::::::::::::::::::::::::::::::::::::::::
class Application < Sinatra::Application

  include Sinatra::AssetHelpers

  register Sinatra::Flash

  # Config::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  set :root, File.dirname(__FILE__)
  set :sprockets, (Sprockets::Environment.new(root) { |env| env.logger = Logger.new(STDOUT) })
  set :assets_prefix, 'compiled'
  set :assets_path, File.join(root, 'public', assets_prefix)
  set :compass_gem_root, Gem.loaded_specs['compass'].full_gem_path
  set :views, Proc.new { File.join(root, 'app/views') }

  configure do
    sprockets.append_path File.join(root, 'app', 'assets', 'stylesheets')
    sprockets.append_path File.join(compass_gem_root, 'frameworks', 'compass', 'stylesheets')
    sprockets.append_path File.join(root, 'app', 'assets', 'javascripts')
  end

  # we are deploying to heroku, which does not have a JVM, which YUI needs, so let's
  # only require and config the compressors / minifiers for dev env
  configure :development do
    require 'yui/compressor'
    require 'uglifier'
    sprockets.css_compressor = YUI::CssCompressor.new
    sprockets.js_compressor  = Uglifier.new(mangle: true)
  end

  # Route Handlers::::::::::::::::::::::::::::::::::::::::::::::::
  # index
  get ('/') { slim :index }

  # list
  post '/list' do
    begin
      data = params[:post]

      bio = data['bio'].empty? ? nil : "q=#{data['bio']}"
      location = data['location'].empty? ? nil : "l=#{data['location']}"
      name = data['name'].empty? ? nil : "n=#{data['name']}"

      path = [bio, location, name] * '&'
      url = URI.escape("http://followerwonk.com/bio/?#{path}")
      puts url

      data = Nokogiri::HTML(open(url))
      @persons = data.css('.person')
    rescue OpenURI::HTTPError => ex
      @reason = "No matches found!"
    end

    slim :list
  end

  #assets
  get '/assets/application.js' do
    content_type('application/javascript')
    settings.sprockets['application.js']
  end

  get '/assets/application.css' do
    content_type('text/css')
    settings.sprockets['application.css']
  end

  %w{jpg png}.each do |format|
    get '/assets/image.#{format}' do |image|
      content_type('image/#{format}')
      settings.sprockets['#{image}.#{format}']
    end
  end

end


__END__



