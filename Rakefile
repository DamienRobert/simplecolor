# encoding: utf-8

require 'rubygems'
require 'rake'

begin
  gem 'yard', '~> 0.8'
  require 'yard'

  YARD::Rake::YardocTask.new  
rescue LoadError => e
  task :yard do
    abort "Please run `gem install yard` to install YARD."
  end
end
task :doc => :yard

begin
  gem 'rubygems-tasks', '~> 0.2'
  require 'rubygems/tasks'

  Gem::Tasks.new(sign: {checksum: true, pgp: true},
                 build: {tar: true}, scm: {status: true}) do |tasks|
    tasks.console.command = 'pry'
  end
rescue LoadError => e
  warn e.message
  warn "Run `gem install rubygems-tasks` to install Gem::Tasks."
end

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
end
