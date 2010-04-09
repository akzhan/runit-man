require 'json'
require 'erubis'
require 'sinatra/base'
require 'sinatra/r18n'
require 'runit-man/erb-to-erubis'
require 'runit-man/helpers'

MIN_TAIL      = 100
MAX_TAIL      = 10000
GEM_FOLDER    = File.expand_path(File.join('..', '..'), File.dirname(__FILE__)).freeze
CONTENT_TYPES = {
  :html => 'text/html',
  :txt  => 'text/plain',
  :css  => 'text/css',
  :js   => 'application/x-javascript',
  :json => 'application/json'
}.freeze

R18n::Filters.on :variables

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
    base_content_type = CONTENT_TYPES.keys.detect do |t|
      request.env['REQUEST_URI'] =~ /\.#{Regexp.escape(t.to_s)}$/
    end || :html
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

  get '/services.json' do
    service_infos.to_json
  end

  def log_of_service(name, count)
    count = count.to_i
    count = MIN_TAIL if count < MIN_TAIL
    count = MAX_TAIL if count > MAX_TAIL
    srv   = ServiceInfo[name]
    return nil if srv.nil? || !srv.logged?
    {
      :name         => name,
      :count        => count,
      :log_location => srv.log_file_location,
      :text         => `tail -n #{count} #{srv.log_file_location}`
    }
  end

  get %r[^/([^/]+)/log(?:/(\d+))?/?$] do |name, count|
    data = log_of_service(name, count)
    return not_found if data.nil?
    @scripts = []
    @title = t.runit.services.log.title(h(name), h(host_name), h(count), h(data[:log_location]))
    erb :log, :locals => data
  end

  get %r[^/([^/]+)/log(?:/(\d+))?\.txt$] do |name, count|
    data = log_of_service(name, count)
    return not_found if data.nil?
    data[:text]
  end

  get '/view' do
    if !request.GET.has_key?('file')
      return not_found
    end
    f = request.GET['file']
    return not_found unless files_to_view.include?(f)
    @scripts = []
    @title = t.runit.view_file.title(h(f), h(host_name))
    erb :view_file, :locals => {
      :name  => f,
      :text  => IO.read(f)
    }
  end

  get '/view.txt' do
    if !request.GET.has_key?('file')
      return not_found
    end
    f = request.GET['file']
    return not_found unless files_to_view.include?(f)
    IO.read(f)
  end

  def log_action(name, text)
    env  = request.env
    addr = env.include?('X_REAL_IP') ? env['X_REAL_IP'] : env['REMOTE_ADDR']
    puts "#{addr} - - [#{Time.now}] \"Do #{text} on #{name}\""
  end

  post '/:name/signal/:signal' do |name, signal|
    srv = ServiceInfo[name]
    return not_found if srv.nil?
    srv.send_signal(signal)
    log_action(name, "send signal \"#{signal}\"")
    ''
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
      all_r_dir    = File.join(RunitMan.all_services_directory, 'runit-man')
      active_r_dir = File.join(RunitMan.active_services_directory, 'runit-man')
      my_dir       = File.join(GEM_FOLDER, 'sv')
      if File.symlink?(all_r_dir)
        File.unlink(all_r_dir)
      end
      File.symlink(my_dir, all_r_dir)
      unless File.symlink?(active_r_dir)
        File.symlink(all_r_dir, active_r_dir)
      end
    end

    def enable_view_of(file_location)
      files_to_view << File.expand_path(file_location, '/')
    end

    def files_to_view
      @files_to_view ||= []
    end

  private
    def create_run_script
      script_name = File.join(GEM_FOLDER, 'sv', 'run')
      File.open(script_name, 'w') do |f|
        f.print Erubis::Eruby.new(IO.read(script_name + '.erb')).result(
          :all_services_directory    => RunitMan.all_services_directory,
          :active_services_directory => RunitMan.active_services_directory,
          :port                      => RunitMan.port,
          :bind                      => RunitMan.respond_to?(:bind) ? RunitMan.bind : nil,
          :server                    => RunitMan.server,
          :files_to_view             => RunitMan.files_to_view
        )
      end
      File.chmod(0755, script_name)
    end
  end
end
