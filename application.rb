require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'coffee-script'
require 'sass'
require 'slim'

class SassEngine < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/assets/sass'

  get 'stylesheets/*.css' do
    filename = params[:splat].first
    sass filename.to_sym
  end

end

class CoffeeEngine < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/assets/coffeescript'

  get '/javascripts/*.js' do
    filename = params[:splat].first
    coffee filename.to_sym
  end

end


class Application < Sinatra::Base

  use SassEngine
  use CoffeeEngine

  set :views,  File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

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

  if __FILE__ == $0
    Application.run! :port => 9494
  end

end


__END__



