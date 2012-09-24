# Represents information about service on logger-enabled host.
class ServiceInfo::Logger < ServiceInfo::Base

  def logger_string
    RunitMan::App.runit_logger
  end

  def logger_name
    (logger_string =~ /^([^\:]+)\:/) ? $1 : logger_string
  end

  def log_base_folder
    (logger_string =~ /^[^\:]+\:([^\:]+)/) ? $1 : nil
  end

  def log_folder
    folder = log_folder_base_name
    (log_base_folder.nil? || folder.nil?) ? folder : File.expand_path(File.join(log_base_folder, folder))
  end

  def log_folder_base_name
    result = super

    # we should remove : from the end of the line for logger installations.
    result = $1  if result =~ /^(.+)\:$/

    result
  end

  # Current log file locations
  def log_file_locations
    folder = log_folder
    return []  if folder.nil? || ! File.directory?(log_folder)

    curdir = File.join(log_folder, Time.now.strftime('%Y-%m-%d'))
    return []  unless File.directory?(curdir)
    r = []
    Dir.foreach(curdir) do |filename|
      next  if ServiceInfo::Base.itself_or_parent?(filename)
      filepath = File.expand_path(filename, curdir)
      next  unless File.file?(filepath) && File.readable?(filepath)

      r << filepath
    end

    r
  end

  # All log file locations
  def all_log_file_locations
    dir_name = log_folder
    return []  if log_folder.nil? || ! File.directory?(dir_name)

    r = []
    Dir.foreach(dir_name) do |subdirname|
      next  if ServiceInfo::Base.itself_or_parent?(subdirname)
      subdirpath = File.expand_path(subdirname, dir_name)
      next  unless File.directory?(subdirpath)

      Dir.foreach(subdirpath) do |filename|
        next  if ServiceInfo::Base.itself_or_parent?(filename)
        filepath = File.expand_path(filename, subdirpath)
        next  unless File.file?(filepath) && File.readable?(filepath)

        label = "#{Utils.host_name}-#{subdirname}-#{filename}"

        stats = File.stat(filepath)
        stat_times = [stats.ctime.utc, stats.mtime.utc]
        min_time, max_time = stat_times.min, stat_times.max

        r << {
          :name     => filename,
          :path     => filepath,
          :subdir   => subdirname,
          :label    => label,
          :size     => stats.size,
          :created  => min_time,
          :modified => max_time
        }
      end
    end

    sorted_file_locations(r)
  end
end

