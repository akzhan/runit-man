require 'runit-man/log_location_cache'

class ServiceInfo
  attr_reader :name

  def initialize(a_name)
    @name  = a_name
    @data  = ''
    @files = {}
  end

  def to_json(*a)
    data = {}
    [ :name, :stat, :active?, :logged?, :switchable?, :run?, :pid, :log_pid, :log_file_location, :finish?, :down?, :started_at, :uptime ].each do |sym|
      data[sym] = send(sym)
    end
    data.to_json(*a)
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

  def down?
    status_byte == 0
  end

  def run?
    status_byte == 1
  end

  def finish?
    status_byte == 2
  end

  def up!
    send_signal :u
  end

  def down!
    send_signal :d
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
    return nil if down?
    st = raw_status
    st.unpack('xxxxxxxxxxxxV').first
  end

  def started_at
    st = raw_status
    return nil unless st
    vals = st.unpack('NN')
    Time.at((vals[0] << 32) + vals[1] - 4611686018427387914)
  end

  def uptime
    return nil if down?
    Time.now - started_at
  end

  def log_pid
    data_from_file(File.join(log_supervise_folder, 'pid'))
  end

  def log_file_location
    rel_path = self.class.log_location_cache[log_pid]
    return nil if rel_path.nil?
    File.expand_path(rel_path, log_run_folder)
  end

  def send_signal(signal)
    return unless supervise?
    File.open(File.join(supervise_folder, 'control'), 'w') { |f| f.print signal.to_s }
  end

  def files_to_view
    return [] unless File.directory?(files_to_view_folder)
    Dir.entries(files_to_view_folder).select do |name|
      File.symlink?(File.join(files_to_view_folder, name))
    end.map do |name|
      File.expand_path(
        File.readlink(File.join(files_to_view_folder, name)),
        files_to_view_folder
      )
    end.select do |file_path|
      File.file?(file_path)
    end 
  end

  def urls_to_view
    return [] unless File.directory?(urls_to_view_folder)
    Dir.entries(urls_to_view_folder).select do |name|
      name =~ /\.url$/ && File.file?(File.join(urls_to_view_folder, name))
    end.map do |name|
      data_from_file(File.join(urls_to_view_folder, name))
    end.select do |url|
      !url.nil?
    end
  end

private
  def inactive_service_folder
    File.join(RunitMan.all_services_directory, name)
  end

  def active_service_folder
    File.join(RunitMan.active_services_directory, name)
  end

  def files_to_view_folder
    File.join(active_service_folder, 'runit-man', 'files-to-view')
  end

  def urls_to_view_folder
    File.join(active_service_folder, 'runit-man', 'urls-to-view')
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

  def raw_status
    # status in daemontools supervise format
    # look at runit's sv.c for details
    if @data == ''
      data = data_from_file(File.join(supervise_folder, 'status'))
      @data = !data.nil? && data.length == 20 ? data : nil
    end
    @data
  end

  def status_byte
    st = raw_status
    return 0 unless st
    st.unpack('xxxxxxxxxxxxxxxxxxxC').first
  end

  def data_from_file(file_name)
    return @files[file_name] if @files.include?(file_name)
    @files[file_name] = self.class.real_data_from_file(file_name)
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

    def real_data_from_file(file_name)
      return nil unless File.readable?(file_name)
      data = IO.read(file_name)
      data.chomp! unless data.nil?
      data.empty? ? nil : data
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
