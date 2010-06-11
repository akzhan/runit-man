class ServiceStatus
  def initialize(data)
    # status in daemontools supervise format
    # look at runit's sv.c for details
    data = !data.nil? && data.length == 20 ? data : nil
    @raw = data.nil? ? nil : data.unpack('NNxxxxVxa1CC')
  end

  def down?
    status_byte == 0
  end

  def run?
    status_byte == 1
  end

  def finish?
    status_byte == 2
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

private
  def status_byte
    @status_byte ||= @raw ? @raw[5] : 0
  end

end

