# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AddZone, "When the paths exist" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_zone = AddZone.new("etc/addzone.conf")
    clear_files
  end
  it { @add_zone.conf_file_path.should == "etc/hosting.conf" }
  it { @add_zone.conf_backup_dir.should == "etc/backup" }
  it { lambda{ @add_zone.backup_conf_file }.should_not raise_error }
  it { @add_zone.conf_backup_file_path.should == "etc/backup/hosting.conf.20110425150015" }

  it { @add_zone.should be_conf_file_dir_exist }
  it { @add_zone.should be_conf_file_exist }
  it { @add_zone.should be_conf_backup_dir_exist }

  it { lambda{ @add_zone.condition_check }.should_not raise_error }

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
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_zone = AddZone.new("etc/addzone.conf")
    @add_zone.conf_file_name = "virtual.conf"
  end
  it { @add_zone.conf_file_name.should == "virtual.conf" }
  it { @add_zone.conf_file_path.should ==
    "etc/virtual.conf" }
  it { @add_zone.conf_backup_file_path.should ==
    "etc/backup/virtual.conf.20110425150015" }
end

describe AddZone, "Simple methods" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_zone = AddZone.new("etc/addzone.conf")
  end
  it { @add_zone.str_time.should == "20110425150015" }
  it { @add_zone.backup_dir("data").should == "data/backup" }
  it { @add_zone.zone_file_name("example.com").should == "example.com.zone" }
  it { @add_zone.base_zone_file_path("example.com").should ==
    "base/example.com.zone" }
end

describe AddZone, "When zone_base is specified" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_zone = AddZone.new("etc/addzone.conf")
    @add_zone.zone_base = "new_base"
  end
  it { @add_zone.base_zone_file_path("example.com").should ==
    "new_base/example.com.zone" }
end

describe AddZone, "各種存在しないファイルパスが指定されている場合" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_zone = AddZone.new("etc/addzone_not_exist.conf")
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

describe AddZone, "存在しないコンフィグファイル" do
  before do
  end
  it "エラーになる" do
    lambda{ @add_zone = AddZone.new("not_exist.conf") }.should raise_error
  end
end
