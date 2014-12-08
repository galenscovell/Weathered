
require 'sinatra'
require 'sinatra/flash'
require 'json'
require 'open-uri'
require_relative 'models'


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
  @location = params[:location]
  site_url = "http://api.openweathermap.org/data/2.5/weather?q=" + @location
  jhash = JSON.parse(open(site_url).read)
  @titles = []
  @infos = []

  jhash['main'].each do |w|
    title_tag = w[0]
    info_item = w[1]
    @titles << "#{title_tag}"
    @infos << "#{info_item}"
  end

  erb :index
end