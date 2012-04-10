$LOAD_PATH.unshift File.expand_path('./lib', File.dirname(__FILE__))
require 'runit-man/version'

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Runit web management tool."
  s.name = 'runit-man'
  s.author = 'Akzhan Abdulin'
  s.email = 'akzhan.abdulin@gmail.com'
  s.date = Time.now.strftime('%Y-%m-%d')
  s.homepage = 'https://github.com/Undev/runit-man'
  s.version = RunitMan::VERSION.dup
  s.requirements << 'none'
  s.require_path = 'lib'
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.extra_rdoc_files = [
    "README.md",
    "INSTALL.md",
    "CHANGELOG.md"
  ]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.add_dependency 'yajl-ruby', '~> 1.0'
  s.add_dependency 'haml', '~> 3.0'
  s.add_dependency 'sinatra', '~> 1.3'
  s.add_dependency 'sinatra-content-for2', '~> 0.2.4'
  s.add_dependency 'i18n', '~> 0.5'
  s.add_dependency 'file-tail', '~> 1.0.7'
  s.add_development_dependency 'rake', ['~> 0.8', '!= 0.9.0']
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'bundler', ['~> 1.0', '> 1.0.10']
  s.add_development_dependency 'yard', '~> 0.7.5'
  s.add_development_dependency 'redcarpet', '~> 1.17.2'
  s.description = File.open(File.join(File.dirname(__FILE__), 'DESCRIPTION')).read
end

