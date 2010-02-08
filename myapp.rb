# encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'erb-to-erubis'
require 'sinatra/content_for'
require 'helpers'

CONTENT_TYPES = {
  :html => 'text/html',
  :css  => 'text/css',
  :js   => 'application/x-javascript',
  :json => 'application/json'
}.freeze

helpers do
  include Helpers
end

before do
  base_content_type = case request.env['REQUEST_URI']
    when /\.css$/  then :css
    when /\.js$/   then :js
    when /\.json$/ then :json
    else                :html
  end
  content_type CONTENT_TYPES[base_content_type], :charset => 'utf-8'
end

get '/' do
  @scripts = [ 'jquery-1.4.1.min' ]
  @title = host_name
  erb :index
end

get '/services' do
  partial :services
end

get '/:name/log' do |name|
  srv = ServiceInfo[name]
  return not_found if srv.nil? || !srv.logged?
  @scripts = []
  @title = "Лог #{name} на #{host_name}"
  erb :log, :locals => {
    :name => name,
    :text => `tail -n 100 #{srv.log_file_location}`
  }
end

post '/:name/:action' do |name, action|
  srv = ServiceInfo[name]
  action = "#{action}!".to_sym
  return not_found if srv.nil? || !srv.respond_to?(action)
  srv.send(action)
  ''
end
