class LogLocationCache
  TIME_LIMIT = 6000

  def initialize
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
    File.join(folder, 'current')
  end

  def log_command(lpid)
    return nil if lpid.nil?
    ps_output = `ps -o args -p #{lpid} 2>&1`.split("\n")
    ps_output.shift
    cmd = ps_output.first
    cmd = cmd.chomp unless cmd.nil?
    cmd = nil if cmd == ''
    cmd
  end

  def log_folder(lpid)
    cmd = log_command(lpid)
    return nil if cmd.nil?
    args = cmd.split(/\s+/).select { |arg| arg !~ /^\-/ }
    return nil if args.shift != 'svlogd'
    args.shift
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
