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

  def files_to_view
    RunitMan.files_to_view.map do |f|
      File.symlink?(f) ? File.expand_path(File.readlink(f), File.dirname(f)) : f
    end.select do |f|
      File.readable?(f)
    end.uniq.sort
  end

  def all_files_to_view
    (files_to_view + service_infos.map do |service|
      service.files_to_view
    end.flatten).uniq.sort
  end

  def service_action(name, action, label)
    partial :service_action, :locals => {
      :name   => name,
      :action => action,
      :label  => label
    }
  end

  def service_signal(name, signal, label)
    partial :service_signal, :locals => {
      :name   => name,
      :signal => signal,
      :label  => label
    }
  end

  def log_link(name, options = {})
    count = (options[:count] || 100).to_i
    title = options[:title].to_s || count
    blank = options[:blank] || false
    hint  = options[:hint].to_s  || ''
    raw   = options[:raw] || false
    hint  = " title=\"#{h(hint)}\"" unless hint.empty?
    blank = blank ? ' target="_blank"' : ''
    "<a#{hint}#{blank} href=\"/#{h(name)}/log#{ (count != 100) ? "/#{count}" : '' }#{ raw ? '.txt' : '' }#footer\">#{h(title)}</a>"
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
