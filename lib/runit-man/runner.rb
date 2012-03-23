require 'optparse'
require 'runit-man/app'

RunitMan::App.set :active_services_directory, RunitMan::App::DEFAULT_ACTIVE_SERVICES_DIR
RunitMan::App.set :all_services_directory,    RunitMan::App::DEFAULT_ALL_SERVICES_DIR
RunitMan::App.set :runit_logger,              RunitMan::App::DEFAULT_LOGGER
RunitMan::App.set :rackup_command_line,       false
RunitMan::App.set :read_write_mode,           :readwrite

OptionParser.new { |op|
  op.banner = 'Usage: runit-man <options>'
  op.separator "Version: #{RunitMan::VERSION}"
  op.separator 'Server options:'
  op.on('-s server') { |val| RunitMan::App.set :server, val }
  op.on('-p port')   { |val| RunitMan::App.set :port, val.to_i }
  op.on('-b addr')   { |val| RunitMan::App.set :bind, val }  if RunitMan::App.respond_to?(:bind)
  op.on('-m mode (rw by default)')   { |val| RunitMan::App.set(:read_write_mode, :readonly)  if val =~ /^read\-only|readonly|ro$/ }
  op.separator 'runit options:'
  op.on("-a active_services_directory (#{RunitMan::App::DEFAULT_ACTIVE_SERVICES_DIR} by default)") { |val| RunitMan::App.set :active_services_directory, val }
  op.on("-f all_services_directory (#{RunitMan::App::DEFAULT_ALL_SERVICES_DIR} by default)")         { |val| RunitMan::App.set :all_services_directory, val }
  op.separator 'runit logger options (now svlogd and logger supported only):'
  op.on("-l runit logger application[:base folder[:priority]] (#{RunitMan::App::DEFAULT_LOGGER} by default)") { |val| RunitMan::App.set :runit_logger, val }
  op.separator 'View options:'
  op.on('-v file_location', 'Enables view of specified file through runit-man') { |val| RunitMan::App.enable_view_of(val) }
  op.on('-u user:password', 'Requires user name with given password to auth') { |val| RunitMan::App.add_user(*(val.split(':', 2))) }
  op.separator 'Configuration options:'
  op.on('--rackup command_line', 'Change directory to config.ru location, set environment by options and execute specified command_line') do |command_line|
    RunitMan::App.set :rackup_command_line, command_line
  end
  op.on_tail('-r', '--register', 'Register as runit service') do
    RunitMan::App.register_as_runit_service
    exit
  end
}.parse!(ARGV.dup)

if RunitMan::App.rackup_command_line
  RunitMan::App.exec_rackup(RunitMan::App.rackup_command_line)
end

RunitMan::App.prepare_to_run

RunitMan::App.run!

