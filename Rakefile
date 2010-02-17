require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Runit web management tool."
  s.name = 'runit-man'
  s.author = 'Akzhan Abdulin'
  s.email = 'akzhan.abdulin@gmail.com'
  s.homepage = 'http://github.com/akzhan/runit-man'
  s.version = "1.3"
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList["{bin,lib,public,views,i18n,sv}/**/*"].to_a
  s.executables << 'runit-man.rb'
  s.add_dependency 'json'
  s.add_dependency 'erubis'
  s.add_dependency 'sinatra'
  s.add_dependency 'sinatra-content-for'
  s.add_dependency 'sinatra-r18n'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'rack-test'
  s.description = File.open(File.join(File.dirname(__FILE__), 'README')).read
end

task :default => [:package]

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
