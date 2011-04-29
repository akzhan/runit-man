$LOAD_PATH.unshift File.expand_path('./lib', File.dirname(__FILE__))

require 'optparse'
require 'runit-man/app'

RunitMan.set :active_services_directory, ENV['RUNIT_ACTIVE_SERVICES_DIR'] || '/etc/service'
RunitMan.set :all_services_directory,    ENV['RUNIT_ALL_SERVICES_DIR'] || '/etc/sv'
RunitMan.set :logger_option,             ENV['RUNIT_LOGGER'] || 'svlogd'
if ENV['RUNIT_MAN_VIEW_FILES']
  ENV['RUNIT_MAN_VIEW_FILES'].split(/\s*\,\s*/).each do |floc|
    RunitMan.enable_view_of(floc)
  end
end

if ENV['RUNIT_MAN_CREDENTIALS']
  RunitMan.add_user(*(ENV['RUNIT_MAN_CREDENTIALS'].split(':', 2)))
end

RunitMan.prepare_to_run

run RunitMan

