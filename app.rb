
require 'sinatra'
require 'sinatra/flash'
require 'json'
require 'open-uri'


configure do
  enable :sessions
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  erb :form
end

post '/enter' do
  @location = (params[:location]).split(' ').join(',')
  site_url = "http://api.openweathermap.org/data/2.5/weather?q=" + @location
  jhash = JSON.parse(open(site_url).read)

  if jhash['cod'] != '404'
    @name = jhash['name'].capitalize
    @country = jhash['sys']['country']
    @coords = jhash['coord']['lon'].to_s + ", " + jhash['coord']['lat'].to_s

    @description = []
    jhash['weather'].each do |type|
      @description << type['description']
    end

    @temp = jhash['main']['temp'].to_i
    @celsius = (@temp - 273.15).round(2)
    @fahr = ((@celsius * 1.8) + 32).round(2)
    @humidity = jhash['main']['humidity']
    @pressure = jhash['main']['pressure']
    @wind = jhash['wind']['speed']
    @wind_direction = jhash['wind']['deg']
  else
    redirect '/', flash[:error] = "Location not found."
  end

  erb :index
end