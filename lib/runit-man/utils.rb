require 'socket'

class Utils
  class << self
    def host_name
      unless @host_name
        begin
          @host_name = Socket.gethostbyname(Socket.gethostname).first
        rescue
          @host_name = Socket.gethostname
        end
      end
      @host_name
    end
  end
end
