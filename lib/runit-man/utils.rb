require 'socket'
require 'i18n'

# Utilities.
class Utils
  class << self
    # Gets local host name.
    # @return [String] Host name.
    # @note Caches host name on first access.
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

    # I18n.t shortcut.
    # @return [String] Translated string.
    def t(*args)
      I18n.t(*args)
    end
  end
end

