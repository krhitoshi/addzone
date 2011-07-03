
AddZone
====

Description
-----------
AddZoneはBINDにゾーンを追加するためのツールです。

コマンド
------
マスターゾーンの追加コマンド: addmaster

スレーブゾーンの追加コマンド: addslave

コンフィグファイル
---------------
ファイルパス: /etc/addzone.conf

ネームサーバの1つ目をマスターサーバとし、2つ目以降のネームサーバをスレーブサーバとして認識します。
<pre>
base:				        ## 基本設定
  conf_file_dir: /var/named/chroot/etc  # コンフィグファイルの存在するディレクトリ
  conf_file_name: hosting.conf	        # 編集するコンフィグファイルの名前

addmaster:   			       	## マスターゾーンの設定
  ip_address: 192.168.10.5		# Aレコードに記載されるデフォルトIPアドレス
  name_servers:				# ネームサーバ 2個以上設定してください
    - name: ns1.example.com		# ネームサーバ1 ホスト名
      ssh: "-p 22 -l root"		# ネームサーバ1 SSHオプション
    - name: ns2.example.com		# ネームサーバ1 ホスト名
      ssh: "-p 22 -l root"		# ネームサーバ1 SSHオプション
  email: root@example.com		# SOAレコードに記載するメールアドレス
  spf: "v=spf1 mx ~all"			# TXTレコードに記載するSPFの設定
  zone_dir: /var/named/chroot/var/named/master # ゾーンファイルの配置ディレクトリ
  bind_user: named			# BINDの実行ユーザ ゾーンファイルのパーミッション
  bind_group: named			# BINDの実行グループ ゾーンファイルのパーミッション

addslave:
  master_ip: 192.168.1.1		## スレーブゾーンの設定
  zone_dir: /var/named/chroot/var/named/slave # ゾーンファイルの配置ディレクトリ
</pre>
