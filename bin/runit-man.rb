#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'

require 'runit-man/app'

OptionParser.new { |op|
  op.on('-s server') { |val| RunitMan.set :server, val }
  op.on('-p port')   { |val| RunitMan.set :port, val.to_i }
  op.on('-b addr')   { |val| RunitMan.set :bind, val }
}.parse!(ARGV.dup)

RunitMan.run!
