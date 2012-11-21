require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'slim'

class Application < Sinatra::Base

  # index
  get ('/') { slim :index }

  # list
  post '/list' do
    bio = params[:post]
    url = URI.escape("http://followerwonk.com/bio/?q=#{bio['bio']}")
    puts url

    data = Nokogiri::HTML(open(url))
    @persons = data.css('.person')
    slim :list
  end

end
