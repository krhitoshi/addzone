
require 'rubygems'
require	'rspec/core/rake_task'

task :default => [:spec]
Rspec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['-cfd --backtrace']
end
