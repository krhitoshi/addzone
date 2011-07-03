# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AddMaster do
  before do
    @add_master = AddMaster.new('etc/addzone.conf')
  end
  before :all do
    test_init
  end
  after :all do
    test_end
  end

  it { @add_master.host_names.should == ["ns1.example.com", "ns2.example.com"] }
  it { @add_master.ip_address.should == "192.168.10.5" }
  it { @add_master.bind_user.should == "hitoshi" }
  it { @add_master.bind_group.should == "staff" }
  it { @add_master.type.should == "master" }
  it { @add_master.base_zone_file_path("example.com").should == "master/example.com.zone" }
  it { @add_master.email.should == "root.example.com" }
  it { @add_master.serial.should == "2011042501" }
  it { @add_master.zone_dir.should == "master" }
  it "spf_include and zone_TXT" do
    @add_master.spf_include.should be_nil
    @add_master.zone_TXT.should == %Q!        IN TXT   "v=spf1 mx ~all"!
    lambda{ @add_master.spf_include = "spf.example.com" }.should_not raise_error

    @add_master.spf_include.should == "spf.example.com"
  end
  it {
    @add_master.zone_SOA.should ==
    "@       IN SOA ns1.example.com. root.example.com.("
  }
  it {
    @add_master.zone_NS.should ==
    "        IN NS    ns1.example.com.\n        IN NS    ns2.example.com."
  }
  it "master zone conf" do
    conf = <<EOS
// example.com : 20110425150015
zone "example.com" {
      type master;
      file "master/example.com.zone";
};

EOS
    @add_master.zone_conf("example.com").should == conf
  end
  it "zone contents" do
    zone = <<EOS
$TTL    600
@       IN SOA ns1.example.com. root.example.com.(
        2011042501  ; Serial
        10800       ; Refresh
        3600        ; Retry
        604800      ; Expire
        600 )       ; Minimum
        IN NS    ns1.example.com.
        IN NS    ns2.example.com.
        IN TXT   "v=spf1 mx ~all"
        IN MX 10 mail
        IN A     192.168.10.5
www     IN A     192.168.10.5
mail    IN A     192.168.10.5
ftp     IN CNAME www
pop     IN CNAME mail
smtp    IN CNAME mail
EOS
    @add_master.zone("example.com").should == zone
  end
end

describe AddMaster, "when the paths not exist" do
  before do
    @add_master = AddMaster.new("etc/addzone_not_exist.conf")
  end
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  it { lambda{ @add_master.condition_check}.should raise_error }
  it { lambda{ @add_master.create_zone_file("example.com") }.should raise_error }
  it { lambda{ @add_master.delete_zone_file("example.com") }.should raise_error }
  it { lambda{ @add_master.add_zone_conf("example.com") }.should raise_error }
end

describe AddMaster, "add zone into config operation" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_master = AddMaster.new("etc/addzone.conf")
    clear_files
  end
  it { lambda{ @add_master.condition_check}.should_not raise_error }
  it { lambda{ @add_master.add_zone_conf("example.com") }.should_not raise_error }
  it {
    @add_master.add_zone_conf("example.com").should == "example.com"
    lambda{ @add_master.add_zone_conf("example.com") }.should raise_error
  }
end

describe AddMaster, "zone creation operation" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_master = AddMaster.new("etc/addzone.conf")
  end
  it { @add_master.should be_zone_dir_exist }
  it { @add_master.should_not be_zone_file_exist("example.com") }
  it { @add_master.should be_zone_file_exist("example.jp") }
  it { @add_master.should be_zone_backup_dir_exist }

  it{
    lambda{ @add_master.create_zone_file("example.com") }.should_not raise_error
    File.should be_exist("master/example.com.zone")
    lambda{ @add_master.delete_zone_file("example.com") }.should_not raise_error
    File.should_not be_exist("master/example.com.zone")
  }
  it { @add_master.create_zone_file("example.com").should == "master/example.com.zone" }
  it {
    @add_master.create_zone_file("example.com")
    lambda{ @add_master.create_zone_file("example.com") }.should raise_error
    @add_master.delete_zone_file("example.com").should == "master/example.com.zone"
  }
  it {
    lambda{ @add_master.delete_zone_file("example.com") }.should raise_error
  }
  after do
    if File.exist? "master/example.com.zone"
      File.delete "master/example.com.zone"
    end
  end
end

describe AddMaster, "ゾーンを削除する場合" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_master = AddMaster.new("etc/addzone.conf")
    clear_files
    @add_master.delete_zone("example.jp")
  end
  it "元のゾーンファイルが存在しないこと" do
    File.should_not be_exist("master/example.jp.zone")
  end
  it "バックアップファイルが保存されていること" do
    File.should be_exist("master/backup/example.jp.zone")
  end
  it "コンフィグファイルのバックアップが保存されていること" do
    File.should be_exist("etc/backup/hosting.conf.20110425150015")
  end
  it "コンフィグファイルからゾーンの設定を削除できていること" do
    lambda{ @add_master.delete_zone_check("example.jp") }.should raise_error AddZone::ConfigureError
  end
end
