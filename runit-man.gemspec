require 'rake'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'runit-man/version'

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Runit web management tool."
  s.name = 'runit-man'
  s.author = 'Akzhan Abdulin'
  s.email = 'akzhan.abdulin@gmail.com'
  s.homepage = 'https://github.com/Undev/runit-man'
  s.version = RunitManVersion::VERSION.dup
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList["{bin,lib,public,views,i18n,sv}/**/*"].exclude(/^\.gitignore|supervise$/).to_a
  s.executables << 'runit-man'
  s.add_dependency 'yajl-ruby', '>= 0.7.8'
  s.add_dependency 'erubis', '>= 2.3.1'
  s.add_dependency 'sinatra', '>= 1.1'
  s.add_dependency 'sinatra-content-for2', '>= 0.2.4'
  s.add_dependency 'i18n', '>= 0.5.0'
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'bundler', '>= 1.0.10'
  s.description = File.open(File.join(File.dirname(__FILE__), 'DESCRIPTION')).read
end

