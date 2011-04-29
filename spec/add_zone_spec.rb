
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'common'
require 'add_zone'

test_init

describe AddZone, "When the paths do not exist" do
  before do
    @manage = AddZone.new
    @manage.conf_file_dir = "not_exist_path"
    @manage.zone_dir      = "not_exist_path"
  end
  it { @manage.should_not be_conf_file_dir_exist }
  it { @manage.should_not be_conf_file_exist }
  it { @manage.should_not be_conf_backup_dir_exist }
  it { lambda{ @manage.backup_conf_file }.should raise_error }
  it { @manage.should_not be_zone_dir_exist }
  it { @manage.should_not be_zone_file_exist("example.com") }
  it { @manage.should_not be_zone_backup_dir_exist }

  it { lambda{ @manage.condition_check}.should raise_error }
  it { lambda{ @manage.conf_file_dir_check}.should raise_error }
  it { lambda{ @manage.conf_file_check }.should raise_error }
  it { lambda{ @manage.conf_backup_dir_check }.should raise_error }

  it { lambda{ @manage.zone_dir_check }.should raise_error }
  it { lambda{ @manage.zone_backup_dir_check }.should raise_error }
end

describe AddZone, "When the paths exist" do
  before do
    @manage = AddZone.new
    @manage.conf_file_dir = "data/etc"
    @manage.zone_dir      = "data/master"
    File.delete "data/etc/hosting.conf"
    FileUtils.copy_file "data/etc/hosting.conf.dist", "data/etc/hosting.conf", true
  end
  it { @manage.conf_file_dir.should == "data/etc" }
  it { @manage.conf_file_path.should == "data/etc/hosting.conf" }
  it { @manage.conf_backup_dir.should == "data/etc/backup" }
  it { lambda{ @manage.backup_conf_file }.should_not raise_error }
  it { @manage.zone_dir.should == "data/master" }
  it { @manage.zone_backup_dir.should == "data/master/backup" }
  it { @manage.conf_backup_file_path.should == "data/etc/backup/hosting.conf.201104251500" }

  it { @manage.should be_conf_file_dir_exist }
  it { @manage.should be_conf_file_exist }
  it { @manage.should be_conf_backup_dir_exist }

  it { @manage.should be_zone_dir_exist }
  it { @manage.should_not be_zone_file_exist("example.com") }
  it { @manage.should be_zone_file_exist("example.jp") }
  it { @manage.should be_zone_backup_dir_exist }

  it { lambda{ @manage.condition_check }.should_not raise_error }
  it { lambda{ @manage.conf_file_dir_check }.should_not raise_error }
  it { lambda{ @manage.conf_file_check }.should_not raise_error }
  it { lambda{ @manage.conf_backup_dir_check }.should_not raise_error }

  it { lambda{ @manage.zone_dir_check }.should_not raise_error }
  it { lambda{ @manage.zone_backup_dir_check }.should_not raise_error }
  it { lambda{ @manage.zone_file_check("example.com") }.should raise_error }

  it { @manage.should_not be_zone_exist("example.com") }
  it { @manage.should be_zone_exist("example.jp") }
  # included 2 empty characters
  it { @manage.should be_zone_exist("example.net") }
  # included tab character
  it { @manage.should be_zone_exist("example.info") }

  it { lambda{ @manage.zone_check("example.com") }.should_not raise_error }
  it { lambda{ @manage.zone_check("example.jp") }.should raise_error }
end

describe AddZone, "When conf_file_name is specified" do
  before do
    @manage = AddZone.new
    @manage.conf_file_name = "virtual.conf"
  end
  it { @manage.conf_file_name.should == "virtual.conf" }
  it { @manage.conf_file_path.should ==
    "/var/named/chroot/etc/virtual.conf" }
  it { @manage.conf_backup_file_path.should ==
    "/var/named/chroot/etc/backup/virtual.conf.201104251500" }
end

describe AddZone, "Simple methods" do
  before do
    @manage = AddZone.new
  end
  it { @manage.str_time.should == "201104251500" }
  it { @manage.backup_dir("data").should == "data/backup" }
  it { @manage.zone_file_name("example.com").should == "example.com.zone" }
  it { @manage.base_zone_file_path("example.com").should ==
    "base/example.com.zone" }
end

describe AddZone, "When zone_base is specified" do
  before do
    @manage = AddZone.new
    @manage.zone_base = "new_base"
  end
  it { @manage.base_zone_file_path("example.com").should ==
    "new_base/example.com.zone" }
end

describe AddZone, "When no condition is specified" do
  before do
    @manage = AddZone.new
  end
  it { @manage.type.should == "base" }
  it { @manage.zone_base.should == "base" }
  it { @manage.conf_file_name.should == "hosting.conf" }
  it { @manage.conf_backup_file_path.should ==
    "/var/named/chroot/etc/backup/hosting.conf.201104251500" }
  it { @manage.conf_file_path.should ==
    "/var/named/chroot/etc/hosting.conf" }
  it { @manage.conf_backup_dir.should == "/var/named/chroot/etc/backup" }
  it { @manage.zone_dir.should == "/var/named/chroot/var/named/base" }
  it { @manage.zone_file_path("example.com").should ==
    "/var/named/chroot/var/named/base/example.com.zone" }
  it { @manage.zone_backup_dir.should ==
    "/var/named/chroot/var/named/base/backup" }
  it { @manage.base_zone_file_path("example.com").should ==
    "base/example.com.zone" }
  it {
    header = <<EOS
// example.com : 201104251500
zone "example.com" {
      type base;
EOS
    @manage.zone_header("example.com").should == header.chomp
  }
  it {
    footer = <<EOS
      file "base/example.com.zone";
};
EOS
    @manage.zone_footer("example.com").should == footer.chomp
  }
end
