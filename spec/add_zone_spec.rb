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
  it { @add_zone.should be_conf_file_dir_exist }
  it { @add_zone.should be_conf_file_exist }
  it { @add_zone.should be_conf_backup_dir_exist }

  it { lambda{ @add_zone.condition_check }.should_not raise_error }

  it { lambda{ @add_zone.add_zone_check("example.com") }.should_not raise_error }
  it { lambda{ @add_zone.add_zone_check("example.jp") }.should raise_error AddZone::ConfigureError }
  it "空白の量が違っても認識できる" do
    lambda{ @add_zone.add_zone_check("example.net") }.should raise_error AddZone::ConfigureError
  end
  it "空白にタブが使われていても認識できる" do
    lambda{ @add_zone.add_zone_check("example.info") }.should raise_error AddZone::ConfigureError
  end
end

describe AddZone, "コンフィグファイルからゾーンを削除する場合" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_zone = AddZone.new("etc/addzone.conf")
    clear_files
    @text = @add_zone.delete_zone_conf("example.jp")
  end
  it "ゾーンの設定を削除できていること" do
    lambda{ @add_zone.delete_zone_check("example.jp") }.should raise_error AddZone::ConfigureError
  end
  it "指定した以外のゾーンの設定が残っていること" do
    lambda{ @add_zone.delete_zone_check("example.net") }.should_not raise_error
    lambda{ @add_zone.delete_zone_check("example.info") }.should_not raise_error
  end
  it "コンフィグファイルにないゾーンを削除しようとするとConfigureErrorを返すこと" do
    lambda{ @add_zone.delete_zone_conf("example.com") }.should raise_error AddZone::ConfigureError
  end
  it "削除したコンフィグファイルのテキストの最後には空白行が含まれていること" do
    (@text.split('\n').last =~ /^\s*$/).should be_true
  end
end

describe AddZone, "ゾーン削除時にゾーン設定の後に空白行がない場合" do
  before :all do
    test_init
  end
  after :all do
    test_end
  end
  before do
    @add_zone = AddZone.new("etc/addzone.conf")
    clear_files
    @text = @add_zone.delete_zone_conf("example.net")
  end
  it "削除したコンフィグファイルのテキストの最後には空白行が含まれないこと" do
    (@text.split('\n').last =~ /^\s*$/).should be_false
  end
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
