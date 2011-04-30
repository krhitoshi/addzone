
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

test_init

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
// example.com : 20110425150015
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
