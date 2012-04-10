# encoding: utf-8

require 'rubygems'

begin
  require 'bundler'
  Bundler.setup(:default, :development, :test)
  Bundler::GemHelper.install_tasks
rescue LoadError
  $stderr.puts "Bundler not available. Install it with: gem install bundler"
end

$LOAD_PATH.unshift('./lib')

require 'runit-man/version'

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = ["-c", "-f progress"]
  end

  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rcov = true
    t.ruby_opts = '-w'
    t.rspec_opts = ["-c", "-f progress"]
    t.rcov_opts = %q[-Ilib --exclude "spec/*,gems/*"]
  end
rescue LoadError
  $stderr.puts "RSpec not available. Install it with: gem install rspec-core rspec-expectations"
end

begin
  require 'yard'

  YARD::Rake::YardocTask.new
rescue LoadError
  $stderr.puts "YARD not available. Install it with: gem install yard"
end

