# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AddSlave, "正常なコンフィグファイルの場合" do
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
  it "コンフィグファイルの設定テキストが正しいこと" do
    conf = <<EOS
// example.com : 20110425150015
zone "example.com" {
      type slave;
      masters { 192.168.1.1; };
      file "slave/example.com.zone";
};

EOS
    @add_slave.zone_conf("example.com").should == conf
  end
end

describe AddSlave, "マスターIPアドレスを変更した場合" do
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
  it "正しく設定されていること" do
    @add_slave.master_ip.should == "192.168.100.1"
  end
  it "コンフィグファイルの設定テキストが正しいこと" do
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


describe AddSlave, "ゾーンを削除する場合" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_slave = AddSlave.new("etc/addzone.conf")
    clear_files
    @add_slave.delete_zone("example.jp")
  end
  it "元のゾーンファイルが存在しないこと" do
    File.should_not be_exist("slave/example.jp.zone")
  end
  it "バックアップファイルが保存されていること" do
    File.should be_exist("slave/backup/example.jp.zone")
  end
  it "コンフィグファイルのバックアップが保存されていること" do
    File.should be_exist("etc/backup/hosting.conf.20110425150015")
  end
  it "コンフィグファイルからゾーンの設定を削除できていること" do
    lambda{ @add_slave.delete_zone_check("example.jp") }.should raise_error AddZone::ConfigureError
  end
end
