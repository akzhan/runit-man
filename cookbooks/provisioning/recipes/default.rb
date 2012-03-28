package "git-core"

gem_package "bundler"

git "/home/runit-man" do
  repository "git://github.com/Undev/runit-man.git"
  enable_submodules true
end

bash "bundle" do
  code "cd /home/runit-man && bundle install --without development"
end

# default svlogd installation
runit_service "runit-man"

# logger installation
runit_service "runit-man-logger"

