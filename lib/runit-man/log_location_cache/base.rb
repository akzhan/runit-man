require 'monitor'

module LogLocationCache; end

class LogLocationCache::Base
  TIME_LIMIT = 600

  def initialize
    @monitor = Monitor.new
    clear
  end

  def [](pid)
    pid = pid.to_i
    loc = nil
    unless pids.include?(pid)
      loc = get_pid_location(pid)
      set_pid_log_location(pid, loc)
    end
    return loc unless loc.nil?
    return nil unless pids.include?(pid)
    pids[pid][:value]
  end

protected
  attr_accessor :query_counter
  attr_accessor :pids
  attr_reader   :monitor

  def not_implemented
    raise NotImplementedError.new
  end

  def get_pid_location(lpid)
    not_implemented
  end

  def clear
    monitor.synchronize do
      self.query_counter = 0
      self.pids = {}
    end
    self
  end

  def remove_old_values
    monitor.synchronize do
      self.query_counter = query_counter + 1
      if query_counter < 10
        return
      end
      self.query_counter = 0
      limit = Time.now - TIME_LIMIT
      pids.keys.each do |pid|
        if pids[pid][:time] < limit
          pids.delete(pid)
        end
      end
    end
    self
  end

  def log_command(lpid)
    return nil if lpid.nil?
    ps_output = `ps -o args -p #{lpid} 2>&1`.split("\n")
    return nil if ps_output.length < 2
    cmd = ps_output[1].chomp
    cmd != '' ? cmd : nil
  end

  def logger_name
    not_implemented
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
    result = args.first
    result
  end

  def log_folder(lpid)
    not_implemented
  end

  def set_pid_log_location(pid, log_location)
    not_implemented
  end
end

