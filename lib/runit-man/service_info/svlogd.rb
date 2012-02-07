require 'runit-man/log_location_cache/svlogd'

class ServiceInfo::Svlogd < ServiceInfo::Base
  SPECIAL_LOG_FILES = %w(lock config state newstate).freeze

  def log_file_path(file_name)
    dir_name = File.dirname(log_file_location)
    File.expand_path(file_name, dir_name)
  end

  def log_files
    r = []
    dir_name = File.dirname(log_file_location)
    Dir.foreach(dir_name) do |name|
      next  if ServiceInfo::Base.itself_or_parent?(name)
      next  if SPECIAL_LOG_FILES.include?(name)
      full_name = File.expand_path(name, dir_name)
      stats = File.stat(full_name)
      stat_times = [stats.ctime.utc, stats.atime.utc, stats.mtime.utc]
      min_time, max_time = stat_times.min, stat_times.max

      label = "#{Utils.host_name}-#{self.name}-#{I18n.l(min_time)}-#{I18n.l(max_time)}.log"
      label = label.gsub(/[\:\s\,]/, '-').gsub(/[\\\/]/, '.')
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
      @log_location_cache ||= LogLocationCache::Svlogd.new
    end

  end


end

