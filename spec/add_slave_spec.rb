# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AddSlave do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_slave = AddSlave.new("etc/addzone.conf")
  end
  it { @add_slave.master_ip.should == "192.168.1.1" }
  it { @add_slave.type.should == "slave" }
  it { @add_slave.zone_dir.should == "slave" }
  it { @add_slave.base_zone_file_path("example.com").should == "slave/example.com.zone" }
  it "slave zone conf" do
    conf = <<EOS
// example.com : 20110425150015
zone "example.com" {
      type slave;
      masters { 192.168.1.1; };
      file "slave/example.com.zone";
};

EOS
    #puts @add_slave.zone_conf("example.com")
    @add_slave.zone_conf("example.com").should == conf
  end
end

describe AddSlave, "マスターIPの変更" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_slave = AddSlave.new("etc/addzone.conf")
    @add_slave.master_ip = "192.168.100.1"
  end
  it { @add_slave.master_ip.should == "192.168.100.1" }
  it "slave zone conf" do
    conf = <<EOS
// example.com : 20110425150015
zone "example.com" {
      type slave;
      masters { 192.168.100.1; };
      file "slave/example.com.zone";
};

EOS
    @add_slave.zone_conf("example.com").should == conf
  end
end
