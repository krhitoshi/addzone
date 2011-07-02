
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

test_init

describe AddMaster do
  before do
    @manage = AddMaster.new('etc/addzone.conf')
  end
  it { @manage.host_names.should == ["ns1.example.com", "ns2.example.com"] }
  it { @manage.ip_address.should == "192.168.10.5" }
  it { @manage.bind_user.should == "named" }
  it { @manage.bind_group.should == "named" }
  it { @manage.type.should == "master" }
  it { @manage.base_zone_file_path("example.com").should == "master/example.com.zone" }
  it { @manage.email.should == "root.example.com" }
  it { @manage.serial.should == "2011042501" }
  it { @manage.zone_dir.should == "/var/named/chroot/var/named/master" }
  it "spf_include and zone_TXT" do
    @manage.spf_include.should be_nil
    @manage.zone_TXT.should == %Q!        IN TXT   "v=spf1 mx ~all"!
    lambda{ @manage.spf_include = "spf.example.com" }.should_not raise_error

    @manage.spf_include.should == "spf.example.com"
  end
  it {
    @manage.zone_SOA.should ==
    "@       IN SOA ns1.example.com. root.example.com.("
  }
  it "zone_SOA with email" do
    @manage.email = "root@example.com"
    @manage.zone_SOA.should ==
      "@       IN SOA ns1.example.com. root.example.com.("
  end
  it {
    @manage.zone_NS.should ==
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
    #puts @manage.zone_conf("example.com")
    @manage.zone_conf("example.com").should == conf
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
    @manage.email = "root@example.com"
    #puts @manage.zone("example.com")
    @manage.zone("example.com").should == zone
  end
end

describe AddMaster, "when the paths not exist" do
  pending
  before do
    @manage = AddMaster.new("etc/addzone.conf")
    @manage.zone_dir      = "not_exist_path"
  end
  it { lambda{ @manage.condition_check}.should raise_error }
  it { lambda{ @manage.create_zone_file("example.com") }.should raise_error }
  it { lambda{ @manage.delete_zone_file("example.com") }.should raise_error }
  it { lambda{ @manage.add_zone_conf("example.com") }.should raise_error }
end

describe AddMaster, "add zone into config operation" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @manage = AddMaster.new("etc/addzone.conf")
    @manage.zone_dir      = "master"
    clear_files
  end
  it { lambda{ @manage.condition_check}.should_not raise_error }
  it { lambda{ @manage.add_zone_conf("example.com") }.should_not raise_error }
  it {
    @manage.add_zone_conf("example.com").should == "example.com"
    lambda{ @manage.add_zone_conf("example.com") }.should raise_error
  }
end

describe AddMaster, "conf file bakup operation" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @manage = AddMaster.new("etc/addzone.conf")
    @manage.zone_dir      = "master"
  puts "clear: " + Dir.pwd
  end
  it { @manage.backup_conf_file.should == "etc/backup/hosting.conf.20110425150015" }
end

describe AddMaster, "zone creation operation" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @manage = AddMaster.new("etc/addzone.conf")
    @manage.zone_dir      = "master"
    @manage.bind_user = "hitoshi"
    @manage.bind_group = "staff"
  end
  it{
    lambda{ @manage.create_zone_file("example.com") }.should_not raise_error
    File.should be_exist("master/example.com.zone")
    lambda{ @manage.zone_file_check("example.com") }.should_not raise_error
    lambda{ @manage.delete_zone_file("example.com") }.should_not raise_error
    File.should_not be_exist("master/example.com.zone")
  }
  it { @manage.create_zone_file("example.com").should == "master/example.com.zone" }
  it {
    @manage.create_zone_file("example.com")
    lambda{ @manage.create_zone_file("example.com") }.should raise_error
    @manage.delete_zone_file("example.com").should == "master/example.com.zone"
  }
  it {
    lambda{ @manage.delete_zone_file("example.com") }.should raise_error
  }
  after do
    if File.exist? "master/example.com.zone"
      File.delete "master/example.com.zone"
    end
  end
end

test_end

