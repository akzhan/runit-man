require File.dirname(__FILE__) + '/../spec_helper'

describe RunitMan do
  def app
    RunitMan::App
  end

  before(:all) do
    RunitMan::App.set :active_services_directory, RunitMan::App::DEFAULT_ACTIVE_SERVICES_DIR
    RunitMan::App.set :all_services_directory,    RunitMan::App::DEFAULT_ALL_SERVICES_DIR
    RunitMan::App.set :rackup_command_line,       false
    RunitMan::App.set :read_write_mode,           :readwrite
    RunitMan::App.set :runit_logger,              RunitMan::App::DEFAULT_LOGGER
  end

  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end

  it "should respond to /services" do
    stub(ServiceInfo).all { [] }

    get '/services'
    last_response.should be_ok
  end
end
