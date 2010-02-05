require 'service_info'
require 'partials'
require 'socket'

module Helpers
  include Rack::Utils
  include Sinatra::Partials
  alias_method :h, :escape_html

  attr_accessor :even_or_odd_state

  def host_name
    unless @host_name
      @host_name = Socket.gethostbyname(Socket.gethostname).first
    end
    @host_name
  end

  def service_infos
    ServiceInfo.all
  end

  def service_action(name, action, label)
    partial :service_action, :locals => {
      :name   => name,
      :action => action,
      :label  => label
    }
  end

  def even_or_odd
    self.even_or_odd_state = !even_or_odd_state
    even_or_odd_state
  end
end
