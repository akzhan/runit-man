require 'runit-man/log_location_cache/logger'

class ServiceInfo::Logger < ServiceInfo::Base

  def log_file_path(file_name)
    dir_name = File.dirname(File.dirname(log_file_location))
    loc = File.expand_path(File.join(file_name, "#{name}.log"), dir_name)
    loc = "#{loc}.gz" unless File.exists?(loc)
    loc = nil unless File.exists?(loc)
    loc
  end

  def log_files
    lfloc = log_file_location
    return []  if lfloc.nil?
    dir_name = File.expand_path(File.dirname(File.dirname(lfloc)))
    return []  unless File.directory?(dir_name)
    r = []
    Dir.foreach(dir_name) do |name|
      next  if ServiceInfo::Base.itself_or_parent?(name)
      full_name = File.expand_path(name, dir_name)
      next  unless File.directory?(full_name)
      file_name = File.join(full_name, "#{self.name}.log")
      label = "#{Utils.host_name}-#{self.name}-#{name}.log"
      unless File.exists?(file_name)
        file_name = "#{file_name}.gz"
        label = "#{label}.gz"
      end
      stats = File.stat(file_name)
      stat_times = [stats.ctime.utc, stats.atime.utc, stats.mtime.utc]
      min_time, max_time = stat_times.min, stat_times.max

      r << {
        :name     => name,
        :label    => label,
        :size     => stats.size,
        :created  => min_time,
        :modified => max_time
      }
    end
    sorted_log_files(r)
  end

  class << self
    def log_location_cache
      @log_location_cache ||= LogLocationCache::Logger.new(RunitMan::App.runit_logger)
    end
  end

end

