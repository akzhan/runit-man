require 'erubis'
require 'sinatra/base'
require 'sinatra/r18n'
require 'runit-man/erb-to-erubis'
require 'runit-man/helpers'

R18n::Filters.on :variables

GEM_FOLDER = File.expand_path(File.join('..', '..'), File.dirname(__FILE__)).freeze

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
  set :root,         GEM_FOLDER

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

  def log_action(name, text)
    env  = request.env
    addr = env.include?('X_REAL_IP') ? env['X_REAL_IP'] : env['REMOTE_ADDR']
    puts "#{addr} - - [#{Time.now}] \"Do #{text} on #{name}\""
  end

  post '/:name/:action' do |name, action|
    srv = ServiceInfo[name]
    action = "#{action}!".to_sym
    return not_found if srv.nil? || !srv.respond_to?(action)
    srv.send(action)
    log_action(name, action)
    ''
  end

  class << self
    def register_as_runit_service
      create_run_script
      return if File.symlink?(File.join(RunitMan.all_services_directory, 'runit-man'))
      do_cmd("ln -sf #{File.join(GEM_FOLDER, 'sv')} #{File.join(RunitMan.all_services_directory, 'runit-man')}")
      do_cmd("ln -sf #{File.join(RunitMan.all_services_directory, 'runit-man')} #{File.join(RunitMan.active_services_directory, 'runit-man')}")
    end

  private
    def do_cmd(command)
      system(command) or raise "Cannot execute #{command}"
    end

    def create_run_script
      script_name = File.join(GEM_FOLDER, 'sv', 'run')
      File.open(script_name, 'w') do |f|
        f.print Erubis::Eruby.new(IO.read(script_name + '.erb')).result(
          :all_services_directory    => RunitMan.all_services_directory,
          :active_services_directory => RunitMan.active_services_directory,
          :port                      => RunitMan.port,
          :bind                      => RunitMan.respond_to?(:bind) ? RunitMan.bind : nil,
          :server                    => RunitMan.server
        )
      end
      File.chmod(0755, script_name)
    end
  end
end
