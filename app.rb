
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
  jhash = JSON.parse(open("http://api.openweathermap.org/data/2.5/weather?q=eugene,or").read)
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