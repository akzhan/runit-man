require File.dirname(__FILE__) + '/../spec_helper'

describe RunitMan do
  def app
    RunitMan
  end

  before(:all) do
    RunitMan.set :read_write_mode,           :readwrite
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