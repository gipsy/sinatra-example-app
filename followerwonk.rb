require 'sinatra'
require 'nokogiri'
require 'open-uri'

class FollowerWonk < Sinatra::Base

  # new search
  get '/' do
    erb :index
  end

  # list
  post '/list' do
    bio = params[:post]
    url = URI.escape("http://followerwonk.com/bio/?q=#{bio['bio']}")
    puts url

    data = Nokogiri::HTML(open(url))
    @persons = data.css('.person')
    erb :list
  end

end
