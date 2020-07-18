# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AddZone::Master do
  before :all do
    test_init
  end
  after :all do
    test_end
  end

  describe AddZone::Master, "正常なコンフィグファイルの場合" do
    before do
      @add_master = AddZone::Master.new('etc/addzone.conf')
    end
    it "IPアドレスが正しいこと" do
      @add_master.ip_address.should == "192.168.10.5"
    end
    it "ネームサーバが正しいこと" do
      @add_master.name_servers.should == 
        [{"name"=>"ns1.example.com", "ssh"=>"-p 22 -l root"},
         {"name"=>"ns2.example.com", "ssh"=>"-p 22 -l root"}]
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
      lambda{ @add_master.add_zone("example.jp") }.should raise_error AddZone::Base::ConfigureError
    end
    it "存在しないゾーンファイルを削除しようとするとエラーを発生すること" do
      lambda{ @add_master.delete_zone("example.com") }.should raise_error AddZone::Base::ConfigureError
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

  describe AddZone::Master, "IPアドレスを変更した場合" do
    before do
      @add_master = AddZone::Master.new('etc/addzone.conf')
      @add_master.ip_address = "192.168.100.10"
    end
    it "IPアドレスが正しいこと" do
      @add_master.ip_address.should == "192.168.100.10"
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

  describe AddZone::Master, "パスが間違っているコンフィグファイルの場合" do
    it "コンストラクタでエラーを発生すること" do
      lambda{ AddZone::Master.new("etc/addzone_not_exist.conf") }.should raise_error
    end
  end

  describe AddZone::Master, "ゾーンの追加をする場合" do
    before do
      @add_master = AddZone::Master.new("etc/addzone.conf")
      clear_files
      @zone_file = @add_master.add_zone("example.com")
    end
    it "コンフィグファイルのバックアップが保存されていること" do
      File.should be_exist("etc/backup/hosting.conf.20110425150015")
    end
    it "ゾーンファイルが生成されていること" do
      File.should be_exist("master/example.com.zone")
    end
    it "返値が生成したゾーンファイルのパスであること" do
      @zone_file.should == "./master/example.com.zone"
    end
    it "コンフィグファイルにゾーンが追加されていること" do
      lambda{ @add_master.add_zone_check("example.com") }.should raise_error AddZone::Base::ConfigureError
    end
  end

  describe AddZone::Master, "ゾーンを削除する場合" do
    before do
      @add_master = AddZone::Master.new("etc/addzone.conf")
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
      lambda{ @add_master.delete_zone_check("example.jp") }.should raise_error AddZone::Base::ConfigureError
    end
  end

  describe AddZone::Master, "ゾーン削除時にゾーン設定の後に空白行がない場合" do
    before do
      @add_master = AddZone::Master.new("etc/addzone.conf")
      clear_files
      @text = @add_master.delete_zone("example.net")
    end

    it "削除したコンフィグファイルのテキストの最後には空白行が含まれないこと" do
      expect(@text.split("\n").last).not_to match /^\s*$/
    end
  end
end
