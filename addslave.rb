#!/usr/bin/ruby -w

$LOAD_PATH << File.dirname(__FILE__)

require 'add_zone'

DEBUG = true
#DEBUG = false

MASTER_IP = "192.168.1.1"

begin
  if ARGV.size != 2 && ARGV.size != 1
    print "USAGE: #{$0} example.com [192.168.1.1] \n"
    exit
  end

  domain = ARGV[0]
  manage =
    if ARGV.size == 2
      AddSlave.new(ARGV[1])
    else
      AddSlave.new(MASTER_IP)
    end

  manage.conf_file_dir = "spec/data/etc"
  manage.zone_dir = "spec/data/slave"

  puts "Domain   : #{domain}"
  puts "Master IP: #{manage.master_ip}"

  manage.condition_check

  puts "Backup Configure File: " + manage.backup_conf_file
  puts "Added Zone Configuration: " + manage.add_zone_conf(domain)


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

rescue => error
  puts
  puts $0 + ": " + error
end
