class LogLocationCache
  TIME_LIMIT = 6000

  def initialize(logger)
    @logger = logger
    clear
  end

  def [](pid)
    pid = pid.to_i
    unless pids.include?(pid)
      set_pid_log_location(pid, get_pid_location(pid))
    end
    pids[pid][:value]
  end

private
  attr_accessor :query_counter
  attr_accessor :pids
  attr_reader   :logger

  def clear
    self.query_counter = 0
    self.pids = {}
    self
  end

  def remove_old_values
    self.query_counter = query_counter + 1
    if query_counter < 1000
      return
    end
    self.query_counter = 0
    limit = Time.now - TIME_LIMIT
    pids.keys.each do |pid|
      if pids[pid][:time] < limit
        pids.remove(pid)
      end
    end
    self
  end

  def get_pid_location(lpid)
    folder = log_folder(lpid)
    return nil if folder.nil?
    return File.join(folder, 'current') if logger == RunitMan::DEFAULT_LOGGER
    loc = File.join(folder, Time.now.strftime('%Y-%m-%d'), "#{log_folder_base_name(lpid)}.log")
    loc = "#{loc}.gz" unless File.exists?(loc)
    loc
  end

  def log_command(lpid)
    return nil if lpid.nil?
    ps_output = `ps -o args -p #{lpid} 2>&1`.split("\n")
    return nil if ps_output.length < 2
    cmd = ps_output[1].chomp
    cmd != '' ? cmd : nil
  end

  def logger_name
    (logger =~ /^([^\:]+)\:/) ? $1 : logger
  end

  def log_base_folder
    (logger =~ /^[^\:]+\:([^\:]+)/) ? $1 : nil
  end

  def log_command_args(lpid)
    cmd = log_command(lpid)
    return nil if cmd.nil?
    args = cmd.split(/\s+/).select { |arg| arg !~ /^\-/ }
    return nil if args.shift !~ /#{Regexp.escape(logger_name)}/
    args
  end

  def log_folder_base_name(lpid)
    args = log_command_args(lpid)
    return nil if args.nil?
    args.first
  end

  def log_folder(lpid)
    folder = log_folder_base_name(lpid) 
    log_base_folder.nil? ? folder : File.join(log_base_folder, folder)
  end

  def log_priority(lpid)
    args = log_command_args(lpid)
    args.nil? ? logger_priority : args.last
  end

  def set_pid_log_location(pid, log_location)
    remove_old_values
    pids[pid.to_i] = {
      :value => log_location,
      :time  => Time.now
    }
    self
  end
end
