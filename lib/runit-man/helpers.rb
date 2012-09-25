require 'runit-man/service_info'
require 'runit-man/partials'
require 'runit-man/utils'
require 'sinatra/content_for2'
require 'i18n'

module Helpers
  include Rack::Utils
  include Sinatra::Partials
  include Sinatra::ContentFor2
  alias_method :h, :escape_html

  attr_accessor :even_or_odd_state

  def addr
    env.include?('X_REAL_IP') ? env['X_REAL_IP'] : env['REMOTE_ADDR']
  end

  def log(s)
    logger.info s
  end

  def host_name
    Utils.host_name
  end

  def t(*args)
    Utils.t(*args)
  end

  def service_infos
    ServiceInfo::Base.all
  end

  def files_to_view
    RunitMan::App.files_to_view.map do |f|
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

  def service_action(name, action, label, enabled = true)
    partial :service_action, :locals => {
      :name    => name,
      :action  => action,
      :label   => label,
      :enabled => enabled
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
    id    = options[:id] || false
    hint  = " title=\"#{h(hint)}\"" unless hint.empty?
    blank = blank ? ' target="_blank"' : ''

    "<a#{hint}#{blank} href=\"/#{name}/log#{ (count != 100) ? "/#{count}" : '' }#{ id ? "/#{id}" : ''  }#{ raw ? '.txt' : '' }#footer\">#{h(title)}</a>"
  end

  def log_downloads_link(name)
    "<a href=\"/#{name}/log-downloads/\">#{h(t('runit.services.log.downloads'))}&hellip;</a>"
  end

  def even_or_odd
    self.even_or_odd_state = !even_or_odd_state
    even_or_odd_state
  end

  KILOBYTE = 1024
  MEGABYTE = 1024 * KILOBYTE
  GIGABYTE = 1024 * MEGABYTE
  TERABYTE = 1024 * GIGABYTE

  def human_bytes(bytes)
    sign = (bytes >= 0) ? '' : '-'
    suffix = 'B'
    bytes = bytes.abs.to_f

    if bytes >= TERABYTE
      bytes /= TERABYTE
      suffix = 'TB'
    elsif bytes >= GIGABYTE
      bytes /= GIGABYTE
      suffix = 'GB'
    elsif bytes >= MEGABYTE
      bytes /= MEGABYTE
      suffix = 'MB'
    elsif bytes >= KILOBYTE
      bytes /= KILOBYTE
      suffix = 'KB'
    end

    bytes = ((bytes * 100 + 0.5).to_i.to_f / 100)

    "#{sign}#{bytes}#{t("runit.services.log.#{suffix}")}"
  end

  def stat_subst(s)
    s.split(/\s/).map do |s|
      if s =~ /(\w+)/
        word = $1

        if t("runit.services.table.subst.#{word}") !~ /translation missing/
          s.sub(word, t("runit.services.table.subst.#{word}"))
        else
          s
        end
      else
        s
      end
    end.join(' ')
  end
end

