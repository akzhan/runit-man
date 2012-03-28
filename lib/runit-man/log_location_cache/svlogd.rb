require 'monitor'

class LogLocationCache::Svlogd < LogLocationCache::Base

protected
  def get_pid_location(lpid)
    folder = log_folder(lpid)
    return nil  if folder.nil?

    File.join(folder, 'current')
  end

  def logger_name
    'svlogd'
  end

  def log_folder(lpid)
    log_folder_base_name(lpid)
  end

  def set_pid_log_location(pid, log_location)
    remove_old_values

    monitor.synchronize do
      pids[pid.to_i] = {
        :value => log_location,
        :time  => Time.now
      }
    end

    self
  end
end

