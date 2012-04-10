# Namespace: Information about service
module ServiceInfo
  class << self
    attr_accessor :klass
  end
end

require 'runit-man/service_info/base'
require 'runit-man/service_info/svlogd'
require 'runit-man/service_info/logger'

