require 'monitor'

class LogLocationCache::Logger < LogLocationCache::Base
  def initialize(logger)
    @logger = logger
  end

protected
  attr_reader   :logger

  def get_pid_location(lpid)
    folder = log_folder(lpid)
    return nil if folder.nil?
    loc = File.join(folder, Time.now.strftime('%Y-%m-%d'), "#{log_folder_base_name(lpid)}.log")
    unless File.exists?(loc)
      loc = "#{loc}.gz"
      loc = nil unless File.exists?(loc)
    end
    loc
  end

  def logger_name
    (logger =~ /^([^\:]+)\:/) ? $1 : logger
  end

  def log_base_folder
    (logger =~ /^[^\:]+\:([^\:]+)/) ? $1 : nil
  end

  def log_priority(lpid)
    args = log_command_args(lpid)
    args.nil? ? logger_priority : args.last
  end

  def set_pid_log_location(pid, log_location)
    remove_old_values
  end
end

