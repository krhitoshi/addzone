
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'add_zone'
require 'add_master'
require 'add_slave'

require 'tmpdir'

TMP_DIR = "#{Dir.tmpdir}/addzone"
DATA_DIR = File.join File.expand_path(File.dirname(__FILE__)), "fixtures"

def test_init
  prepare_data_files
  $PREV_DIR = Dir.pwd
  Dir.chdir TMP_DIR
end

def test_end
  remove_data_files
  Dir.chdir $PREV_DIR
end

def prepare_data_files
  FileUtils.rm_rf TMP_DIR if File.directory? TMP_DIR
  Dir.mkdir TMP_DIR
  Dir.mkdir File.join TMP_DIR, "etc"
  Dir.mkdir File.join TMP_DIR, "etc", "backup"
  Dir.mkdir File.join TMP_DIR, "master"
  Dir.mkdir File.join TMP_DIR, "master", "backup"
  Dir.mkdir File.join TMP_DIR, "slave"
  Dir.mkdir File.join TMP_DIR, "slave", "backup"
  FileUtils.copy_file File.join(DATA_DIR, "addzone.conf"),
  File.join(TMP_DIR, "etc", "addzone.conf"), true
  FileUtils.copy_file File.join(DATA_DIR, "addzone_not_exist.conf"),
  File.join(TMP_DIR, "etc", "addzone_not_exist.conf"), true
   FileUtils.copy_file File.join(DATA_DIR, "hosting.conf.dist"),
  File.join(TMP_DIR, "etc", "hosting.conf"), true
  FileUtils.copy_file File.join(DATA_DIR, "example.jp.zone"),
  File.join(TMP_DIR, "master", "example.jp.zone"), true
end

def remove_data_files
  FileUtils.rm_rf TMP_DIR
end

def clear_files
  FileUtils.rm(Dir.glob("etc/backup/*"))
  FileUtils.rm(Dir.glob("master/backup/*"))
  File.delete "etc/hosting.conf" if File.exist?("etc/hosting.conf")
  FileUtils.copy_file File.join(DATA_DIR, "hosting.conf.dist"),
  "etc/hosting.conf", true
end

class Time
  def Time.now
    local(2011,4,25,15,00,15)
  end
end
