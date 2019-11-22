# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe AddZone::Base do
  before :all do
    test_init
  end
  after :all do
    test_end
  end

  describe AddZone::Base, "正常なコンフィグファイルの場合" do
    before do
      @add_zone = AddZone::Base.new("etc/addzone.conf")
      clear_files
    end
    it "コンフィグファイルにないゾーンが検出できること" do
      lambda{ @add_zone.add_zone_check("example.com") }.should_not raise_error
    end
    it "コンフィグファイルにあるゾーンが検出できること" do
      lambda{ @add_zone.add_zone_check("example.jp") }.should raise_error AddZone::Base::ConfigureError
    end
    it "空白の量が違っても認識できること" do
      lambda{ @add_zone.add_zone_check("example.net") }.should raise_error AddZone::Base::ConfigureError
    end
    it "空白にタブが使われていても認識できること" do
      lambda{ @add_zone.add_zone_check("example.info") }.should raise_error AddZone::Base::ConfigureError
    end
  end

  describe AddZone::Base, "各種存在しないファイルパスが指定されている場合" do
    it "コンストラクタでエラーを発生すること" do
      lambda{ AddZone::Base.new("etc/addzone_not_exist.conf") }.should raise_error
    end
  end

  describe AddZone::Base, "存在しないコンフィグファイル" do
    before do
    end
    it "エラーになる" do
      lambda{ @add_zone = AddZone::Base.new("not_exist.conf") }.should raise_error
    end
  end

    describe AddZone::Base, "設定を反映させるためにBINDをリロードできる" do
    before do
      @add_zone = AddZone::Base.new("etc/addzone.conf")
    end
    it "エラーは発生しない" do
      lambda{ @add_zone.rndc_reload }.should_not raise_error
    end
  end

  describe AddZone::Base, "正常なコンフィグファイルをチェックする場合" do
    before do
      pending "コマンドがない" unless AddZone::Base.named_checkconf_exist?
      @add_zone = AddZone::Base.new("etc/addzone.conf")
    end
    it "エラーは発生しない" do
      lambda{ @add_zone.named_checkconf }.should_not raise_error
    end
  end

  describe AddZone::Base, "異常なコンフィグファイルをチェックする場合" do
    before do
      pending "コマンドがない" unless AddZone::Base.named_checkconf_exist?
      @add_zone = AddZone::Base.new("etc/addzone_wrong.conf")
    end
    it "エラーが発生する" do
      lambda{ @add_zone.named_checkconf }.should raise_error AddZone::Base::NamedCheckConfError
    end
  end
end
