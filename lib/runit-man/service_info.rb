require 'runit-man/log_location_cache'

class ServiceInfo
  ALL_SERVICES_FOLDER = '/etc/sv'.freeze
  ACTIVE_SERVICES_FOLDER = '/etc/service'.freeze

  attr_reader :name

  def initialize(a_name)
    @name = a_name
  end
1
  def logged?
    File.directory?(log_supervise_folder)
  end

  def stat
    return 'inactive' unless supervise?
    r = 'indeterminate'
    File.open(File.join(supervise_folder, 'stat'), 'r') { |f| r = f.gets }
    r
  end

  def active?
    supervise?
  end

  def run?
    stat =~ /\brun\b/
  end

  def up!
    send_signal! :u
  end

  def down!
    send_signal! :d
  end

  def restart!
    down!
    up!
  end

  def pid
    r = nil
    if supervise?
      File.open(File.join(supervise_folder, 'pid'), 'r') { |f| r = f.gets }
    end
    r = r.chomp unless r.nil?
    r = nil if r == ''
    r
  end

  def log_pid
    r = nil
    if logged?
      File.open(File.join(log_supervise_folder, 'pid'), 'r') { |f| r = f.gets }
    end
    r = r.chomp unless r.nil?
    r = nil if r == ''
    r
  end

  def log_file_location
    self.class.log_location_cache[log_run_folder, log_pid]
  end

private
  def supervise_folder
    File.join('', 'etc', 'service', name, 'supervise')
  end

  def log_run_folder
    File.join('', 'etc', 'service', name, 'log')
  end

  def log_supervise_folder
    File.join(log_run_folder, 'supervise')
  end

  def supervise?
    File.directory?(supervise_folder)
  end

  def send_signal!(signal)
    return unless supervise?
    File.open(File.join(supervise_folder, 'control'), 'w') { |f| f.print signal.to_s }
  end

  class << self
    def all
      all_service_names.sort.map do |name|
        ServiceInfo.new(name)
      end
    end

    def [](name)
      all_service_names.include?(name) ? ServiceInfo.new(name) : nil
    end

    def log_location_cache
      unless @log_location_cache
        @log_location_cache = LogLocationCache.new
      end
      @log_location_cache
    end

  private
    def itself_or_parent?(name)
      name == '.' || name == '..'
    end

    def active_service_names
      return [] unless File.directory?(ACTIVE_SERVICES_FOLDER)
      Dir.entries(ACTIVE_SERVICES_FOLDER).reject do |name|
        full_name = File.join(ACTIVE_SERVICES_FOLDER, name)
        itself_or_parent?(name) || (!File.symlink?(full_name) && !File.directory?(full_name))
      end
    end

    def inactive_service_names
      return [] unless File.directory?(ALL_SERVICES_FOLDER)
      actives = active_service_names
      Dir.entries(ALL_SERVICES_FOLDER).reject do |name|
        full_name = File.join(ALL_SERVICES_FOLDER, name)
        itself_or_parent?(name) || !File.directory?(full_name) || actives.include?(name)
      end
    end

    def all_service_names
      (active_service_names + inactive_service_names)
    end

    def runsvdir_pid
      pid = `pgrep -x runsvdir`.split("\n").first
      pid = pid.chomp unless pid.nil?
      pid
    end
  end
end
