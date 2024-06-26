
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

```
base:                           ## 基本設定
  chroot_dir: /var/named/chroot # chrootディレクトリ
  working_dir: /var/named       # workingディレクトリ
  conf_file_dir: /etc/named     # 編集するコンフィグファイルの存在するディレクトリ
  conf_file_name: zones.conf    # 編集するコンフィグファイルの名前

addmaster:                      ## マスターゾーンの設定
  ip_address: 192.168.10.5      # Aレコードに記載されるデフォルトIPアドレス
  name_servers:                 # ネームサーバ 2個以上設定してください
    - name: ns1.example.com     # ネームサーバ1 ホスト名
      ssh: "-p 22 -l root"      # ネームサーバ1 SSHオプション
    - name: ns2.example.com     # ネームサーバ2 ホスト名
      ssh: "-p 22 -l root -t"   # ネームサーバ2 SSHオプション
      sudo: true                # ネームサーバ2 コマンド実行時に sudo を使うオプション
  email: root@example.com       # SOAレコードに記載するメールアドレス
  spf: "v=spf1 mx ~all"         # TXTレコードに記載するSPFの設定
  zone_dir: master              # ゾーンファイルの配置ディレクトリ
  bind_user: named              # BINDの実行ユーザ ゾーンファイルのパーミッション
  bind_group: named             # BINDの実行グループ ゾーンファイルのパーミッション

addslave:
  master_ip: 192.168.1.1        ## スレーブゾーンの設定
  zone_dir: slave               # ゾーンファイルの配置ディレクトリ
```
