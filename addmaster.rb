#!/usr/bin/ruby -w

$LOAD_PATH << File.dirname(__FILE__)

require 'add_zone'
require 'fileutils'

DEBUG = true
#DEBUG = false

HOSTS = ["ns1.example.com", "ns2.example.com"]
IP_ADDRESS = "192.168.10.5"
SSH_PORT = 10022

begin
  manage = AddMaster.new(HOSTS, IP_ADDRESS)
  manage.email = "root@example.com"
  manage.zone_base = "master" # default "master"
  manage.zone_dir = "spec/data/master"
  manage.conf_file_dir = "spec/data/etc"
  manage.bind_user = "hitoshi" # "named"
  manage.bind_group = "staff"  # "named"

  if ARGV.size != 2 && ARGV.size != 1
    print "USAGE: #{$0} example.com [#{manage.ip_address}] \n"
    exit
  end

  domain  = ARGV[0]

  if ARGV.size == 2
    manage.ip_address = ARGV[1]
  end

  puts "Domain   : #{domain}"
  puts "IP Adress: #{manage.ip_address}"
  manage.condition_check

  puts "Backup Configure File: " + manage.backup_conf_file
  puts "Added Zone Configuration: " + manage.add_zone_conf(domain)
  puts "Create Zone File: " + manage.create_zone_file(domain)

  checkconf = "/usr/sbin/named-checkconf  -t /var/named/chroot/ /etc/named.conf"
  puts checkconf

  unless DEBUG
    puts `#{checkconf}`
    raise 'ERROR: named-checkconf failed' if $? != 0
  end

  rndc_reload = "/usr/sbin/rndc reload"
  puts rndc_reload

  unless DEBUG
    puts `#{rndc_reload}`
    raise 'ERROR: rndc reload failed' if $? != 0
  end

  HOSTS[1..-1].each do |host|
    ns2 = "ssh -p #{SSH_PORT} root@#{host} /root/bin/addslave.rb #{domain}"
    puts ns2
    puts `#{ns2}` unless DEBUG
  end

  sleep 1 unless DEBUG
  check_dns = "/root/bin/checkdns.rb #{domain}"
  puts check_dns
  puts `#{check_dns}` unless DEBUG
rescue => error
  puts
  puts $0 + ": " + error
end
