require 'rubygems'
require 'sinatra'
require 'facebook_oauth'

configure do
  set :sessions, true
  @@config = YAML.load_file("config.yml") rescue nil || {}
end

before do
  next if request.path_info =~ /ping$/
  @user = session[:user]
  @client = FacebookOAuth::Client.new(
    :application_id => ENV['APPLICATION_ID'] || @@config['application_id'],
    :application_secret => ENV['APPLICATION_SECRET'] || @@config['application_secret'],
    :callback => ENV['CALLBACK_URL'] || @@config['callback_url'],
    :token => session[:access_token]
  )
end

get '/' do
  redirect '/news' if @user
  erb :home
end

get '/auth' do
  redirect @client.authorize_url
end

get '/callback' do
  access_token = @client.authorize(:code => params[:code])
  session[:access_token] = access_token.token
  session[:user] = @client.me.info['name']
  redirect '/'
end

get '/news' do
  @news = @client.me.home['data']
  erb :news
end

get '/logout' do
  session.delete(:user)
  redirect '/'
end