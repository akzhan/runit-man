$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rack/test'
require 'rspec/core'

require 'runit-man/app'

class RunitMan::App
  # set test environment
  set :environment,  :test
  set :raise_errors, true
  set :logging,      false
end

RSpec.configure do |conf|
  conf.mock_with :rr
  conf.include   Rack::Test::Methods
end
