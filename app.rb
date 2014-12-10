
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
  session.clear
  erb :form
end



get '/main' do
  if !session[:location].nil?
    @location = session[:location]
  else
    @location = (params[:location]).split(' ').join(',')
    session[:location] = @location
  end

  site_url = "http://api.openweathermap.org/data/2.5/weather?q=" + @location
  jhash = JSON.parse(open(site_url).read)

  if jhash['cod'] != '404'
    @name = jhash['name'].capitalize
    @time = Time.now
    @country = jhash['sys']['country']
    @coords = jhash['coord']['lat'].to_s + ", " + jhash['coord']['lon'].to_s

    @description = []
    jhash['weather'].each do |type|
      @description << type['description']
    end

    @temp = jhash['main']['temp'].to_i
    @celsius = (@temp - 273.15).round(2)
    @fahr = ((@celsius * 1.8) + 32).round(2)
    @humidity = jhash['main']['humidity']
    @pressure = jhash['main']['pressure']
    @pressure_percent = ((@pressure / 1013.25) * 100).round(1)
    @wind = jhash['wind']['speed']
    @wind_direction = jhash['wind']['deg'].to_i

    session[:location] = @location
    session[:name] = @name
    session[:coords] = @coords
    session[:country] = @country
  
  else
    redirect '/', flash[:error] = "Location not found."
  end

  erb :main
end



get '/forecast/:id' do
  @date = params[:id].to_i
  forecast_coords = session[:coords].gsub(", ", "&lon=")
  
  forecast_url = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=" + forecast_coords + "&cnt=3&mode=json"
  jhash = JSON.parse(open(forecast_url).read)

  specific_day = jhash['list'][@date]

  @description = []
  specific_day['weather'].each do |type|
      @description << type['description']
  end

  @temp = specific_day['temp']['day'].to_i
  @celsius = (@temp - 273.15).round(2)
  @fahr = ((@celsius * 1.8) + 32).round(2)
  @humidity = specific_day['humidity']
  @pressure = specific_day['pressure']
  @pressure_percent = ((@pressure / 1013.25) * 100).round(1)
  @wind = specific_day['speed']
  @wind_direction = specific_day['deg'].to_i
  @time = Time.now

  erb :forecast
end