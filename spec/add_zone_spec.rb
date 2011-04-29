
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'add_zone'

class Time
  def Time.now
    local(2011,4,25,15,00)
  end
end

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

describe AddMaster, "when wrong argument of host_names" do
  it { lambda{ AddMaster.new("ns1.example.com",
                                    "192.168.10.1") }.should raise_error }
  it { lambda{ AddMaster.new(["ns1.example.com"],
                                    "192.168.10.1") }.should raise_error }
end

describe AddMaster do
  before do
    @manage = AddMaster.new(["ns1.example.com", "ns2.example.com"],
                                   "192.168.10.1")
  end
  it { @manage.host_names.should == ["ns1.example.com", "ns2.example.com"] }
  it { @manage.ip_address.should == "192.168.10.1" }
  it { @manage.bind_user.should == "named" }
  it { @manage.bind_group.should == "named" }
  it { @manage.type.should == "master" }
  it { @manage.base_zone_file_path("example.com").should == "master/example.com.zone" }
  it { @manage.email.should == "root.ns1.example.com" }
  it {
    @manage.email = "root@example.com"
    @manage.email.should == "root.example.com"
  }
  it {
    @manage.email = "root.example.com"
    @manage.email.should == "root.example.com"
  }
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
    "@       IN SOA ns1.example.com. root.ns1.example.com.("
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
// example.com : 201104251500
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
        IN A     192.168.10.1
www     IN A     192.168.10.1
mail    IN A     192.168.10.1
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
  before do
    @manage = AddMaster.new(["ns1.example.com", "ns2.example.com"],
                                   "192.168.10.1")
    @manage.conf_file_dir = "not_exist_path"
    @manage.zone_dir      = "not_exist_path"
  end
  it { lambda{ @manage.condition_check}.should raise_error }
  it { lambda{ @manage.create_zone_file("example.com") }.should raise_error }
  it { lambda{ @manage.delete_zone_file("example.com") }.should raise_error }
  it { lambda{ @manage.add_zone_conf("example.com") }.should raise_error }
end

describe AddMaster, "add zone into config operation" do
  before do
    @manage = AddMaster.new(["ns1.example.com", "ns2.example.com"],
                                   "192.168.10.1")
    @manage.conf_file_dir = "data/etc"
    @manage.zone_dir      = "data/master"
    File.delete "data/etc/hosting.conf"
    FileUtils.copy_file "data/etc/hosting.conf.dist", "data/etc/hosting.conf", true
  end
  it { lambda{ @manage.condition_check}.should_not raise_error }
  it { lambda{ @manage.add_zone_conf("example.com") }.should_not raise_error }
  it {
    @manage.add_zone_conf("example.com").should == "example.com"
    lambda{ @manage.add_zone_conf("example.com") }.should raise_error
  }
  after do
    File.delete "data/etc/hosting.conf"
    FileUtils.copy_file "data/etc/hosting.conf.dist", "data/etc/hosting.conf", true
  end
end

describe AddMaster, "conf file bakup operation" do
  before do
    @manage = AddMaster.new(["ns1.example.com", "ns2.example.com"],
                                   "192.168.10.1")
    @manage.conf_file_dir = "data/etc"
    @manage.zone_dir      = "data/master"
  end
  it { @manage.backup_conf_file.should == "data/etc/backup/hosting.conf.201104251500" }
  after do
    File.delete "data/etc/backup/hosting.conf.201104251500"
  end
end

describe AddMaster, "zone creation operation" do
  before do
    @manage = AddMaster.new(["ns1.example.com", "ns2.example.com"],
                                   "192.168.10.1")
    @manage.conf_file_dir = "data/etc"
    @manage.zone_dir      = "data/master"
    @manage.bind_user = "hitoshi"
    @manage.bind_group = "staff"
  end
  it{
    lambda{ @manage.create_zone_file("example.com") }.should_not raise_error
    File.should be_exist("data/master/example.com.zone")
    lambda{ @manage.zone_file_check("example.com") }.should_not raise_error
    lambda{ @manage.delete_zone_file("example.com") }.should_not raise_error
    File.should_not be_exist("data/master/example.com.zone")
  }
  it { @manage.create_zone_file("example.com").should == "data/master/example.com.zone" }
  it {
    @manage.create_zone_file("example.com")
    lambda{ @manage.create_zone_file("example.com") }.should raise_error
    @manage.delete_zone_file("example.com").should == "data/master/example.com.zone"
  }
  it {
    lambda{ @manage.delete_zone_file("example.com") }.should raise_error
  }
  after do
    if File.exist? "data/master/example.com.zone"
      File.delete "data/master/example.com.zone"
    end
  end
end

describe AddSlave do
  before do
    @manage = AddSlave.new("192.168.0.1")
  end
  it { @manage.master_ip.should == "192.168.0.1" }
  it { @manage.type.should == "slave" }
  it { @manage.zone_dir.should == "/var/named/chroot/var/named/slave" }
  it { @manage.base_zone_file_path("example.com").should == "slave/example.com.zone" }
  it "slave zone conf" do
    conf = <<EOS
// example.com : 201104251500
zone "example.com" {
      type slave;
      masters { 192.168.0.1; };
      file "slave/example.com.zone";
};
EOS
    #puts @manage.zone_conf("example.com")
    @manage.zone_conf("example.com").should == conf
  end
end
