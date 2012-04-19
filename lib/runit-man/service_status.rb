# Represents service status in daemontools supervise format.
# @note see runit's sv.c source code for details.
class ServiceStatus
  # Size of status data in bytes
  STATUS_SIZE = 20
  # Service is down.
  S_DOWN      = 0
  # Service is running.
  S_RUN       = 1
  # Service is finishing.
  S_FINISH    = 2

  # Initializes service status by binary data.
  # @param [String] data Binary data of service status in daemontools supervise format.
  def initialize(data)
    @raw = nil
    unless data.nil?
      data_size = data.respond_to?(:bytesize) ? data.bytesize : data.size
      if data_size == STATUS_SIZE
        @raw = data.unpack('NNxxxxVxa1CC')
      end
    end
  end

  # Is service inactive?
  def inactive?
    @raw.nil?
  end

  # Is service down?
  def down?
    status_byte == S_DOWN
  end

  # Is service running?
  def run?
    status_byte == S_RUN
  end

  # Is service finishing?
  def finish?
    status_byte == S_FINISH
  end

  # Gets service process id.
  # @return [Fixnum] Process id.
  def pid
    @pid ||= down? ? nil : @raw[2]
  end

  # Gets service start time.
  # @return [Time] Service start time.
  def started_at
    # from TAI to Unix
    @started_at ||= @raw ? Time.at((@raw[0] << 32) + @raw[1] - 4611686018427387914) : nil
  end

  # Gets service uptime in seconds.
  # @return [Float] Service uptime in seconds if running; otherwise nil.
  def uptime
    @uptime ||= down? ? nil : Time.now - started_at
  end

  # Is service want up?
  def want_up?
    @raw && !pid && @raw[3] == 'u'
  end

  # Is service want down?
  def want_down?
    pid && @raw[3] == 'd'
  end

  # Is service got TERM signal?
  def got_term?
    pid && @raw[4] != 0
  end

  # Gets service status in string format.
  # @return [String] Service status in string format.
  def to_s
    return 'inactive'  if inactive?

    # try to mimics stat behaviour to minimize readings
    result = status_string
    result += ', got TERM'  if got_term?
    result += ', want down'  if want_down?
    result += ', want up'  if want_up?
    result
  end

private
  def status_byte
    @status_byte ||= @raw ? @raw[5] : 0
  end

  def status_string
    case status_byte
      when S_DOWN; 'down'
      when S_RUN; 'run'
      when S_FINISH; 'finish'
    end
  end
end

