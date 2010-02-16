require File.join(File.dirname(__FILE__), '..', 'lib', 'runit-man', 'app')

require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'

class RunitMan
  # set test environment
  set :environment,  :test
  set :raise_errors, true
  set :logging,      false
end

Spec::Runner.configure do |conf|
  conf.mock_with :rr
  conf.include   Rack::Test::Methods
end
