
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'add_zone'
require 'add_master'
require 'add_slave'

require 'tmpdir'

TMPDIR = "#{Dir.tmpdir}/addzone"
DATA_DIR = File.join File.expand_path(File.dirname(__FILE__)), "data"

def test_init
  prepare_data_files
  $PREV_DIR = Dir.pwd
  Dir.chdir TMPDIR
end

def test_end
  remove_data_files
  Dir.chdir $PREV_DIR
end

def prepare_data_files
  FileUtils.rm_rf TMPDIR if File.directory? TMPDIR
  Dir.mkdir TMPDIR
  Dir.mkdir File.join TMPDIR, "etc"
  Dir.mkdir File.join TMPDIR, "etc", "backup"
  Dir.mkdir File.join TMPDIR, "master"
  Dir.mkdir File.join TMPDIR, "master", "backup"
  Dir.mkdir File.join TMPDIR, "slave"
  Dir.mkdir File.join TMPDIR, "slave", "backup"
  FileUtils.copy_file File.join(DATA_DIR, "/etc/hosting.conf.dist"),
  File.join(TMPDIR, "etc", "hosting.conf"), true
  FileUtils.copy_file File.join(DATA_DIR, "/master/example.jp.zone"),
  File.join(TMPDIR, "master", "example.jp.zone"), true
end

def remove_data_files
  FileUtils.rm_rf TMPDIR
end

def clear_files
  FileUtils.rm(Dir.glob("etc/backup/*"))
  FileUtils.rm(Dir.glob("master/backup/*"))
  File.delete "etc/hosting.conf" if File.exist?("etc/hosting.conf")
  FileUtils.copy_file File.join(DATA_DIR, "etc/hosting.conf.dist"),
  "etc/hosting.conf", true
end


class Time
  def Time.now
    local(2011,4,25,15,00,15)
  end
end
