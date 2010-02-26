require 'socket'
require 'runit-man/service_info'
require 'runit-man/partials'
require 'sinatra/content_for'

module Helpers
  include Rack::Utils
  include Sinatra::Partials
  include Sinatra::ContentFor
  alias_method :h, :escape_html

  attr_accessor :even_or_odd_state

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

  def stat_subst(s)
    s.split(/\s/).map do |s|
      if s =~ /(\w+)/ && t.runit.services.table.subst[$1].translated?
        s.sub(/\w+/, t.runit.services.table.subst[$1].to_s)
      else
        s
      end
    end.join(' ')
  end
end
