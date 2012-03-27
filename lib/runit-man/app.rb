# encoding: utf-8

require 'fileutils'
require 'yajl'
require 'haml'
require 'i18n'
require 'sinatra/base'
require 'file/tail'
require 'runit-man/helpers'
require 'runit-man/version'

if RUBY_VERSION >= '1.9'
  Encoding.default_external = "utf-8"
  Encoding.default_internal = "utf-8"
end

class RunitMan::App < Sinatra::Base
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
  DEFAULT_LOGGER              = 'svlogd'.freeze
  DEFAULT_ALL_SERVICES_DIR    = '/etc/sv'.freeze
  DEFAULT_ACTIVE_SERVICES_DIR = '/etc/service'.freeze

  set :environment,   :production
  set :root,          GEM_FOLDER

  enable :logging, :dump_errors, :static
  disable :raise_errors

  helpers do
    include Helpers

    def readonly?
      @read_write_mode == :readonly
    end

    def sendfile?
      !!File.instance_methods.detect { |m| "#{m}" == 'trysendfile' }
    end
  end

  def self.i18n_location
    File.join(GEM_FOLDER, 'i18n')
  end

  def self.setup_i18n_files
    files = []
    Dir.glob("#{i18n_location}/*.yml") do |full_path|
      next unless File.file?(full_path)
      files << full_path
    end
    I18n.load_path = files
    I18n.reload!
    nil 
  end

  configure do
    RunitMan::App.setup_i18n_files
    haml_options = { :ugly => true }
    haml_options[:encoding] = 'utf-8' if defined?(Encoding)
    set :haml, haml_options
  end

  before do
    case RunitMan::App.runit_logger
    when RunitMan::App::DEFAULT_LOGGER;
      ServiceInfo.klass = ServiceInfo::Svlogd
    else
      ServiceInfo.klass = ServiceInfo::Logger
    end
    @read_write_mode = RunitMan::App.read_write_mode
    @scripts = []
    base_content_type = CONTENT_TYPES.keys.detect do |t|
      request.env['REQUEST_URI'] =~ /\.#{Regexp.escape(t.to_s)}$/
    end || :html
    content_type CONTENT_TYPES[base_content_type], :charset => 'utf-8'
    headers({
      'X-Powered-By' => 'runit-man',
      'X-Version' => RunitMan::VERSION
    })
    parse_language(request.env['HTTP_ACCEPT_LANGUAGE'])
  end

  def setup_i18n(locales)
    locales.each do |locale|
      if I18n.available_locales.include?(locale)
        I18n.locale = locale
        break
      end
    end
  end

  def parse_language(header)
    weighted_locales = []
    if header
      header.split(',').each do |s|
        if s =~ /^(.+)\;q\=(\d(?:\.\d)?)$/
          weighted_locales << { :locale => $1.to_sym, :weight => $2.to_f }
        else
          weighted_locales << { :locale => s.to_sym, :weight => 1.0 }
        end
      end
    end
    weighted_locales << { :locale => :en, :weight => 0.0 }
    if weighted_locales.length >= 2
      weighted_locales.sort! do |a, b|
        b[:weight] <=> a[:weight]
      end
    end
    locales = weighted_locales.map { |wl| wl[:locale] }
    setup_i18n(locales)
  end

  get '/' do
    @scripts = %w[ jquery-1.7.2.min runit-man ]
    @title = host_name
    haml :index
  end

  get '/info' do
    @server = env['SERVER_SOFTWARE']
    @large_files = !!(@server =~ /rainbows/i)
    @rack_version = Rack.release
    @sendfile = sendfile? && @large_files
    haml :info
  end

  get '/services' do
    partial :services
  end

  get '/services.json' do
    Yajl::Encoder.encode(service_infos)
  end

  def log_of_service(name, count, no)
    count = count.to_i
    count = MIN_TAIL if count < MIN_TAIL
    count = MAX_TAIL if count > MAX_TAIL
    srv   = ServiceInfo.klass[name]
    return nil if srv.nil? || !srv.logged?
    text = ''
    File::Tail::Logfile.open(srv.log_file_location, :backward => count, :return_if_eof => true) do |log|
      log.tail do |line|
        text += line
      end
    end

    {
      :name  => name,
      :count => count,
      :logs  => [
        {
          :location => srv.log_file_location,
          :text     => text,
          :id       => 0
        }
      ]
    }
  end

  def data_of_file_view(request)
    if !request.GET.has_key?('file')
      return nil
    end
    file_path = request.GET['file']
    return nil unless all_files_to_view.include?(file_path)
    text = IO.read(file_path)
    {
       :name => file_path,
       :text => text
    }
  end

  get %r[^/([^/]+)/log(?:/(\d+))?/?$] do |name, count|
    data = log_of_service(name, count, nil)
    return not_found if data.nil?
    @title = t('runit.services.log.title', :name => name, :host => host_name, :count => count)
    haml :log, :locals => data
  end

  get %r[^/([^/]+)/log(?:/(\d+))?/(\d+)\.txt$] do |name, d1, d2|
    if d2
      count, no = d1, d2
    else
      count, no = nil, d1
    end
    no = no.to_i
    data = log_of_service(name, count, no)
    return not_found if data.nil?
    data[:logs][no][:text]
  end

  get %r[^/([^/]+)/log\-downloads/?$] do |name|
    srv = ServiceInfo.klass[name]
    return not_found if srv.nil? || !srv.logged?
    haml :log_downloads, :locals => {
      :name  => name,
      :files => srv.log_files
    }
  end

  get %r[^/([^/]+)/log\-download/(.+)$] do |name, file_name|
    srv = ServiceInfo.klass[name]
    return not_found if srv.nil? || !srv.logged?
    f = srv.log_files.detect { |f| f[:name] == file_name }
    return not_found unless f
    send_file(srv.log_file_path(file_name), :type => 'text/plain', :disposition => 'attachment', :filename => f[:label], :last_modified => f[:modified].httpdate)
  end

  get '/view' do
    data = data_of_file_view(request)
    if data.nil?
      return not_found
    end
    @title = t('runit.view_file.title', :file => data[:name], :host => host_name)
    content_type CONTENT_TYPES[:html], :charset => 'utf-8'
    haml :view_file, :locals => data 
  end

  get '/view.txt' do
    data = data_of_file_view(request)
    if data.nil?
      return not_found
    end
    content_type CONTENT_TYPES[:txt], :charset => 'utf-8'
    data[:text]
  end

  def log_action(name, text)
    env  = request.env
    log "#{addr} - - [#{Time.now}] \"Do #{text} on #{name}\""
  end

  def log_denied_action(name, text)
    env  = request.env
    log "#{addr} - - [#{Time.now}] \"Receive #{text} for #{name}. Denied.\""
  end

  post '/:name/signal/:signal' do |name, signal|
    unless readonly?
      service = ServiceInfo.klass[name]
      return not_found if service.nil?
      service.send_signal(signal)
      log_action(name, "send signal \"#{signal}\"")
    else
      log_denied_action(name, "signal \"#{signal}\"")
    end
    ''
  end

  post '/:name/:action' do |name, action|
    unless readonly?
      service = ServiceInfo.klass[name]
      action = "#{action}!".to_sym
      return not_found if service.nil? || !service.respond_to?(action)
      service.send(action)
      log_action(name, action)
    else
      log_denied_action(name, action)
    end
    ''
  end

  class << self
    def exec_rackup(command)
      ENV['RUNIT_ALL_SERVICES_DIR']    = RunitMan::App.all_services_directory
      ENV['RUNIT_ACTIVE_SERVICES_DIR'] = RunitMan::App.active_services_directory
      ENV['RUNIT_LOGGER']              = RunitMan::App.runit_logger
      ENV['RUNIT_MAN_VIEW_FILES']      = RunitMan::App.files_to_view.join(',')
      ENV['RUNIT_MAN_CREDENTIALS']     = RunitMan::App.allowed_users.keys.map { |user| "#{user}:#{RunitMan.allowed_users[user]}" }.join(',')
      ENV['RUNIT_MAN_READWRITE_MODE']  = RunitMan::App.read_write_mode.to_s

      Dir.chdir(File.dirname(__FILE__))
      exec(command)
    end

    def register_as_runit_service
      all_r_dir    = File.join(RunitMan::App.all_services_directory, 'runit-man')
      active_r_dir = File.join(RunitMan::App.active_services_directory, 'runit-man')
      my_dir       = File.join(GEM_FOLDER, 'sv')
      log_dir      = File.join(all_r_dir, 'log')
      if File.symlink?(all_r_dir)
        File.unlink(all_r_dir)
      end
      unless File.directory?(all_r_dir)
        FileUtils.mkdir_p(log_dir)
        create_log_run_script(all_r_dir)
      end
      create_run_script(all_r_dir)
      unless File.symlink?(active_r_dir)
        File.symlink(all_r_dir, active_r_dir)
      end
    end

    def enable_view_of(file_location)
      files_to_view << File.expand_path(file_location, '/')
    end

    def add_user(name, password)
      allowed_users[name] = password
    end

    def files_to_view
      @files_to_view ||= []
    end

    def allowed_users
      @allowed_users ||= {}
    end

    def prepare_to_run
      unless allowed_users.empty?
        use Rack::Auth::Basic, 'runit-man' do |username, password|
          allowed_users.include?(username) && allowed_users[username] == password
        end
      end
    end

  private
    def create_run_script(dir)
      require 'erb'
      script_name   = File.join(dir, 'run')
      template_name = File.join(GEM_FOLDER, 'sv', 'run.erb')
      all_services_directory    = RunitMan::App.all_services_directory
      active_services_directory = RunitMan::App.active_services_directory
      port                      = RunitMan::App.port
      bind                      = RunitMan::App.bind
      server                    = RunitMan::App.server
      files_to_view             = RunitMan::App.files_to_view
      logger                    = RunitMan::App.runit_logger
      auth                      = RunitMan::App.allowed_users
      rackup_command_line       = RunitMan::App.rackup_command_line
      read_write_mode           = RunitMan::App.read_write_mode.to_s
      File.open(script_name, 'w') do |script_source|
        script_source.print ERB.new(IO.read(template_name)).result(binding())
      end
      File.chmod(0755, script_name)
    end

    def create_log_run_script(dir)
      require 'erb'
      script_name   = File.join(dir, 'log', 'run')
      template_name = File.join(GEM_FOLDER, 'sv', 'log', 'run.erb')
      logger        = RunitMan::App.runit_logger
      File.open(script_name, 'w') do |script_source|
        script_source.print ERB.new(IO.read(template_name)).result(binding())
      end
      File.chmod(0755, script_name)
    end
  end
end

