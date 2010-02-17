#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'

require 'runit-man/app'

RunitMan.set :active_services_directory, '/etc/service'
RunitMan.set :all_services_directory,    '/etc/sv'

OptionParser.new { |op|
  op.on('-s server') { |val| RunitMan.set :server, val }
  op.on('-p port')   { |val| RunitMan.set :port, val.to_i }
  op.on('-b addr')   { |val| RunitMan.set :bind, val }
  op.on('-a active_services_directory (/etc/service by default)') { |val| RunitMan.set :active_services_directory, val }
  op.on('-f all_services_directory (/etc/sv by default)')         { |val| RunitMan.set :all_services_directory, val }
  op.on_tail('-r', '--register', 'Register as runit service') do
    RunitMan.register_as_runit_service
    exit
  end
}.parse!(ARGV.dup)

RunitMan.run!
