require File.join(File.dirname(__FILE__), '..', 'myapp.rb')

require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end
