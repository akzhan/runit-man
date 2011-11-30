#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'syslogger'

class Runner
  attr_accessor :nextnr, :children

  def initialize
    @terminate = false
    self.nextnr = 1
    self.children = []
  end

  def create_child
    nr = nextnr
    self.nextnr += 1
    pid = fork do
      logger = Syslogger.new("testsv#{nr}", Syslog::LOG_PID, Syslog::LOG_LOCAL1)
      loop do
        logger.info "You from worker #{nr}"
        sleep 5
      end
    end
    children << pid
  end

  def terminate!
    @terminate = true
  end

  def terminate?
    !! @terminate
  end

  def run
    10.times { create_child }
    until terminate?
      child_pid = Process.wait(-1, Process::WNOHANG)
      if child_pid
        children.delete_if { |pid| pid == child_pid }
        create_child
      else
        sleep 1
      end
    end
    children.each { |pid| Process.kill('TERM', pid) }
  end
end

runner = Runner.new

Signal.trap('TERM') do
  runner.terminate!
end

runner.run
