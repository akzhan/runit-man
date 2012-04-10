# Represents information about service on svlogd-enabled host.
class ServiceInfo::Svlogd < ServiceInfo::Base
  SPECIAL_LOG_FILES = %w(lock config state newstate).freeze

  def logger_name
    'svlogd'
  end

  def log_folder
    log_folder_base_name
  end

  def log_file_locations
    folder = log_folder
    return nil  if folder.nil?

    [ File.join(folder, 'current') ]
  end

  def all_log_file_locations
    dir_name = log_folder
    return []  if dir_name.nil? || ! File.directory?(dir_name)
    r = []
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
    sorted_file_locations(r)
  end
end

