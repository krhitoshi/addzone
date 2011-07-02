# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AddZone, "When the paths do not exist" do
  before do
    @add_zone = AddZone.new
    @add_zone.conf_file_dir = "not_exist_path"
    @add_zone.zone_dir      = "not_exist_path"
  end
  it { @add_zone.should_not be_conf_file_dir_exist }
  it { @add_zone.should_not be_conf_file_exist }
  it { @add_zone.should_not be_conf_backup_dir_exist }
  it { lambda{ @add_zone.backup_conf_file }.should raise_error }
  it { @add_zone.should_not be_zone_dir_exist }
  it { @add_zone.should_not be_zone_file_exist("example.com") }
  it { @add_zone.should_not be_zone_backup_dir_exist }

  it { lambda{ @add_zone.condition_check}.should raise_error }
  it { lambda{ @add_zone.conf_file_dir_check}.should raise_error }
  it { lambda{ @add_zone.conf_file_check }.should raise_error }
  it { lambda{ @add_zone.conf_backup_dir_check }.should raise_error }

  it { lambda{ @add_zone.zone_dir_check }.should raise_error }
  it { lambda{ @add_zone.zone_backup_dir_check }.should raise_error }
end

describe AddZone, "When the paths exist" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_zone = AddZone.new
    @add_zone.conf_file_dir = "etc"
    @add_zone.zone_dir      = "master"
    clear_files
  end
  it { @add_zone.conf_file_dir.should == "etc" }
  it { @add_zone.conf_file_path.should == "etc/hosting.conf" }
  it { @add_zone.conf_backup_dir.should == "etc/backup" }
  it { lambda{ @add_zone.backup_conf_file }.should_not raise_error }
  it { @add_zone.zone_dir.should == "master" }
  it { @add_zone.zone_backup_dir.should == "master/backup" }
  it { @add_zone.conf_backup_file_path.should == "etc/backup/hosting.conf.20110425150015" }

  it { @add_zone.should be_conf_file_dir_exist }
  it { @add_zone.should be_conf_file_exist }
  it { @add_zone.should be_conf_backup_dir_exist }

  it { @add_zone.should be_zone_dir_exist }
  it { @add_zone.should_not be_zone_file_exist("example.com") }
  it { @add_zone.should be_zone_file_exist("example.jp") }
  it { @add_zone.should be_zone_backup_dir_exist }

  it { lambda{ @add_zone.condition_check }.should_not raise_error }
  it { lambda{ @add_zone.conf_file_dir_check }.should_not raise_error }
  it { lambda{ @add_zone.conf_file_check }.should_not raise_error }
  it { lambda{ @add_zone.conf_backup_dir_check }.should_not raise_error }

  it { lambda{ @add_zone.zone_dir_check }.should_not raise_error }
  it { lambda{ @add_zone.zone_backup_dir_check }.should_not raise_error }
  it { lambda{ @add_zone.zone_file_check("example.com") }.should raise_error }

  it { @add_zone.should_not be_zone_exist("example.com") }
  it { @add_zone.should be_zone_exist("example.jp") }
  # included 2 empty characters
  it { @add_zone.should be_zone_exist("example.net") }
  # included tab character
  it { @add_zone.should be_zone_exist("example.info") }

  it { lambda{ @add_zone.zone_check("example.com") }.should_not raise_error }
  it { lambda{ @add_zone.zone_check("example.jp") }.should raise_error }
end

describe AddZone, "When conf_file_name is specified" do
  before do
    @add_zone = AddZone.new
    @add_zone.conf_file_name = "virtual.conf"
  end
  it { @add_zone.conf_file_name.should == "virtual.conf" }
  it { @add_zone.conf_file_path.should ==
    "/var/named/chroot/etc/virtual.conf" }
  it { @add_zone.conf_backup_file_path.should ==
    "/var/named/chroot/etc/backup/virtual.conf.20110425150015" }
end

describe AddZone, "Simple methods" do
  before do
    @add_zone = AddZone.new
  end
  it { @add_zone.str_time.should == "20110425150015" }
  it { @add_zone.backup_dir("data").should == "data/backup" }
  it { @add_zone.zone_file_name("example.com").should == "example.com.zone" }
  it { @add_zone.base_zone_file_path("example.com").should ==
    "base/example.com.zone" }
end

describe AddZone, "When zone_base is specified" do
  before do
    @add_zone = AddZone.new
    @add_zone.zone_base = "new_base"
  end
  it { @add_zone.base_zone_file_path("example.com").should ==
    "new_base/example.com.zone" }
end

describe AddZone, "When no condition is specified" do
  before do
    @add_zone = AddZone.new
  end
  it { @add_zone.addzone_conf.should == "/etc/addzone.conf" }
  it { @add_zone.type.should == "base" }
  it { @add_zone.zone_base.should == "base" }
  it { @add_zone.conf_file_name.should == "hosting.conf" }
  it { @add_zone.conf_backup_file_path.should ==
    "/var/named/chroot/etc/backup/hosting.conf.20110425150015" }
  it { @add_zone.conf_file_path.should ==
    "/var/named/chroot/etc/hosting.conf" }
  it { @add_zone.conf_backup_dir.should == "/var/named/chroot/etc/backup" }
  it { @add_zone.zone_dir.should == "/var/named/chroot/var/named/base" }
  it { @add_zone.zone_file_path("example.com").should ==
    "/var/named/chroot/var/named/base/example.com.zone" }
  it { @add_zone.zone_backup_dir.should ==
    "/var/named/chroot/var/named/base/backup" }
  it { @add_zone.base_zone_file_path("example.com").should ==
    "base/example.com.zone" }
  it {
    header = <<EOS
// example.com : 20110425150015
zone "example.com" {
      type base;
EOS
    @add_zone.zone_header("example.com").should == header.chomp
  }
  it {
    footer = <<EOS
      file "base/example.com.zone";
};
EOS
    @add_zone.zone_footer("example.com").should == footer.chomp
  }
end

describe AddZone, "正常なコンフィグファイルの読み込み" do
  before do
    @add_zone = AddZone.new("spec/fixtures/addzone.conf")
  end
  it "コンストラクタでコンフィグファイルを指定できる" do
    @add_zone.addzone_conf.should == "spec/fixtures/addzone.conf"
  end
  it "root_dir" do
    @add_zone.root_dir.should == "/var/named/chroot"
  end
end

describe AddZone, "Load wrong config file" do
  before do
    @add_zone = AddZone.new("not_exist.conf")
  end
  it { lambda{ @add_zone.addzone_conf_check }.should raise_error }
  it { lambda{ @add_zone.load_addzone_conf }.should raise_error }
end
