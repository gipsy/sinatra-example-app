# Libraries::::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'sinatra'
require 'sinatra/static_assets'
require 'sprockets'
require 'nokogiri'
require 'open-uri'
require 'slim'
require 'sass'
require 'coffee-script'

# Modules::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
class Assets < Sinatra::Base
  configure do
    set :assets, (Sprockets::Environment.new { |env|
      env.append_path(settings.root + "/assets/images")
      env.append_path(settings.root + "/assets/javascripts")
      env.append_path(settings.root + "/assets/stylesheets")

      # compress everything in production
      if ENV["RACK_ENV"] == 'production'
        env.js_compressor  = YUI::JavaScriptCompressor.new
        env.css_compressor = YUI::CssCompressor.new
      end
    })
  end

  get '/assets/app.js' do
    content_type('application/javascript')
    settings.assets['app.js']
  end

  get '/assets/app.css' do
    content_type('text/css')
    settings.assets['app.css']
  end

  %w{jpg png}.each do |format|
    get '/assets/image.#{format}' do |image|
      content_type('image/#{format}')
      settings.assets['#{image}.#{format}']
    end
  end
end

# Application::::::::::::::::::::::::::::::::::::::::::::::::::::::
class Application < Sinatra::Base

  use Assets
  register Sinatra::StaticAssets

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

end


__END__



