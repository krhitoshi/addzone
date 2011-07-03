# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AddMaster, "正常なコンフィグファイルの場合" do
  before do
    @add_master = AddMaster.new('etc/addzone.conf')
  end
  before :all do
    test_init
  end
  after :all do
    test_end
  end

  it "spf_include and zone_TXT" do
    @add_master.spf_include.should be_nil
    lambda{ @add_master.spf_include = "spf.example.com" }.should_not raise_error

    @add_master.spf_include.should == "spf.example.com"
  end
  it "コンフィグファイルへの設定テキストが正しいこと" do
    conf = <<EOS
// example.com : 20110425150015
zone "example.com" {
      type master;
      file "master/example.com.zone";
};

EOS
    @add_master.zone_conf("example.com").should == conf
  end
  it "すでに存在するゾーンを追加しようとするとエラーを発生すること" do
    lambda{ @add_master.add_zone_conf("example.jp") }.should raise_error
  end
  it "存在しないゾーンファイルを削除しようとするとエラーを発生すること" do
    lambda{ @add_master.delete_zone_file("example.com") }.should raise_error
  end
  it "ゾーン情報が正しいこと" do
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

describe AddMaster, "IPアドレスを変更した場合" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_master = AddMaster.new('etc/addzone.conf')
    @add_master.ip_address = "192.168.100.10"
  end
  it "ゾーン情報が正しいこと" do
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
        IN A     192.168.100.10
www     IN A     192.168.100.10
mail    IN A     192.168.100.10
ftp     IN CNAME www
pop     IN CNAME mail
smtp    IN CNAME mail
EOS
    @add_master.zone("example.com").should == zone
  end
end

describe AddMaster, "パスが間違っているコンフィグファイルの場合" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  it "コンストラクタでエラーを発生すること" do
    lambda{ AddMaster.new("etc/addzone_not_exist.conf") }.should raise_error
  end
end

describe AddMaster, "コンフィグファイルへのゾーン追加" do
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
  it { lambda{ @add_master.add_zone_conf("example.com") }.should_not raise_error }
end

describe AddMaster, "ゾーンファイルを生成する場合" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_master = AddMaster.new("etc/addzone.conf")
    @zone_file = @add_master.create_zone_file("example.com")
  end
  it "ゾーンファイルが保存されていること" do
    File.should be_exist("master/example.com.zone")
  end
  it "返値が正しいこと" do
    @zone_file.should == "master/example.com.zone"
  end
  after do
    if File.exist? "master/example.com.zone"
      File.delete "master/example.com.zone"
    end
  end
end

describe AddMaster, "ゾーンファイルを削除する場合" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_master = AddMaster.new("etc/addzone.conf")
    @add_master.delete_zone_file("example.jp")
  end
  it "ゾーンファイルが存在しないこと" do
    File.should_not be_exist("master/example.jp.zone")
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
