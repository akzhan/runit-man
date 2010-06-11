class ServiceStatus
  STATUS_SIZE = 20
  # state
  S_DOWN      = 0
  S_RUN       = 1
  S_FINISH    = 2

  def initialize(data)
    # status in daemontools supervise format
    # look at runit's sv.c for details
    data = (!data.nil? && data.length == STATUS_SIZE) ? data : nil
    @raw = data.nil? ? nil : data.unpack('NNxxxxVxa1CC')
  end

  def inactive?
    @raw.nil?
  end

  def down?
    status_byte == S_DOWN
  end

  def run?
    status_byte == S_RUN
  end

  def finish?
    status_byte == S_FINISH
  end

  def pid
    @pid ||= down? ? nil : @raw[2]
  end

  def started_at
    # from TAI to Unix
    @started_at ||= @raw ? Time.at((@raw[0] << 32) + @raw[1] - 4611686018427387914) : nil
  end

  def uptime
    @uptime ||= down? ? nil : Time.now - started_at
  end

  def want_up?
    @raw && !pid && @raw[3] == 'u'
  end

  def want_down?
    pid && @raw[3] == 'd'
  end

  def got_term?
    pid && @raw[4] != 0
  end

  def to_s
    # try to mimics stat behaviour to minimize readings
    result = status_string
    result += ', got TERM' if got_term?
    result += ', want down' if want_down?
    result += ', want up' if want_up?
    result 
  end

private
  def status_byte
    @status_byte ||= @raw ? @raw[5] : 0
  end

  def status_string
    case status_byte
      when S_DOWN then 'down'
      when S_RUN then 'run'
      when S_FINISH then 'finish'
    end
  end
end

