
require 'rubygems'
require	'rspec/core/rake_task'

task :default => [:spec]
Dir.chdir "spec"
Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = '*_spec.rb'
  spec.rspec_opts = ['-cfd --backtrace']
end
