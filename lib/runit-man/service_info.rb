require 'runit-man/log_location_cache'

class ServiceInfo
  attr_reader :name

  def initialize(a_name)
    @name = a_name
  end

  def logged?
    File.directory?(log_supervise_folder)
  end

  def stat
    r = data_from_file(File.join(supervise_folder, 'stat'))
    r ? r : 'inactive'
  end

  def active?
    File.directory?(active_service_folder) || File.symlink?(active_service_folder)
  end

  def switchable?
    File.symlink?(active_service_folder) || File.directory?(inactive_service_folder)
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

  def switch_down!
    down!
    File.unlink(active_service_folder)
  end

  def switch_up!
    File.symlink(inactive_service_folder, active_service_folder)
  end

  def restart!
    down!
    up!
  end

  def pid
    data_from_file(File.join(supervise_folder, 'pid'))
  end

  def log_pid
    data_from_file(File.join(log_supervise_folder, 'pid'))
  end

  def log_file_location
    rel_path = self.class.log_location_cache[log_pid]
    return nil if rel_path.nil?
    File.expand_path(rel_path, log_run_folder)
  end

private
  def inactive_service_folder
    File.join(RunitMan.all_services_directory, name)
  end

  def active_service_folder
    File.join(RunitMan.active_services_directory, name)
  end

  def supervise_folder
    File.join(active_service_folder, 'supervise')
  end

  def log_run_folder
    File.join(active_service_folder, 'log')
  end

  def log_supervise_folder
    File.join(log_run_folder, 'supervise')
  end

  def supervise?
    File.directory?(supervise_folder)
  end

  def data_from_file(file_name)
    return nil unless File.readable?(file_name)
    r = IO.read(file_name)
    r = r.chomp unless r.nil?
    r.empty? ? nil : r
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
      return [] unless File.directory?(RunitMan.active_services_directory)
      Dir.entries(RunitMan.active_services_directory).reject do |name|
        full_name = File.join(RunitMan.active_services_directory, name)
        itself_or_parent?(name) || (!File.symlink?(full_name) && !File.directory?(full_name))
      end
    end

    def inactive_service_names
      return [] unless File.directory?(RunitMan.all_services_directory)
      actives = active_service_names
      Dir.entries(RunitMan.all_services_directory).reject do |name|
        full_name = File.join(RunitMan.all_services_directory, name)
        itself_or_parent?(name) || !File.directory?(full_name) || actives.include?(name)
      end
    end

    def all_service_names
      (active_service_names + inactive_service_names)
    end

  end
end
