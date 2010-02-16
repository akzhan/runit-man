#!/usr/bin/env ruby
# encoding: utf-8

require 'sinatra/base'
require 'sinatra/r18n'
require 'runit-man/erb-to-erubis'
require 'runit-man/helpers'

R18n::Filters.on :variables

CONTENT_TYPES = {
  :html => 'text/html',
  :css  => 'text/css',
  :js   => 'application/x-javascript',
  :json => 'application/json'
}.freeze


class RunitMan < Sinatra::Base
  set :environment,  :production
  set :static,       true
  set :logging,      true
  set :dump_errors,  true
  set :raise_errors, false
  set :root,         File.expand_path(File.join('..', '..'), File.dirname(__FILE__))

  register Sinatra::R18n

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
    @title = t.runit.services.log.title(h(name), h(host_name))
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
end
