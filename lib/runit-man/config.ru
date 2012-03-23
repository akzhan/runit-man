$LOAD_PATH.unshift File.expand_path('..', File.dirname(__FILE__))

require 'runit-man/app'

RunitMan::App.set :active_services_directory, ENV['RUNIT_ACTIVE_SERVICES_DIR'] || RunitMan::App::DEFAULT_ACTIVE_SERVICES_DIR
RunitMan::App.set :all_services_directory,    ENV['RUNIT_ALL_SERVICES_DIR'] || RunitMan::App::DEFAULT_ALL_SERVICES_DIR
RunitMan::App.set :runit_logger,              ENV['RUNIT_LOGGER'] || RunitMan::App::DEFAULT_LOGGER
RunitMan::App.set :read_write_mode,           (ENV['RUNIT_READWRITE_MODE'] || 'rw').to_sym

if ENV['RUNIT_MAN_VIEW_FILES']
  ENV['RUNIT_MAN_VIEW_FILES'].split(/\s*\,\s*/).each do |floc|
    RunitMan::App.enable_view_of(floc)
  end
end

if ENV['RUNIT_MAN_CREDENTIALS']
  ENV['RUNIT_MAN_CREDENTIALS'].split(/\s*\,\s*/).each do |cred|
    RunitMan::App.add_user(*(cred.split(':', 2)))
  end
end

RunitMan::App.prepare_to_run

run RunitMan::App

