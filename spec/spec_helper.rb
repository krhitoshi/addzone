
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'add_zone'
require 'add_master'
require 'add_slave'

require 'tmpdir'

def test_init
  Dir.chdir File.dirname(__FILE__)
  clear_files
end

def clear_files
  FileUtils.rm(Dir.glob("data/etc/backup/*"))
  FileUtils.rm(Dir.glob("data/master/backup/*"))
  File.delete "data/etc/hosting.conf" if File.exist?("data/etc/hosting.conf")
  FileUtils.copy_file "data/etc/hosting.conf.dist", "data/etc/hosting.conf", true
end

class Time
  def Time.now
    local(2011,4,25,15,00,15)
  end
end
