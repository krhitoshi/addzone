#!/usr/bin/ruby

class DNS
  def initialize(host)
    @host = host
  end
  def check(domain)
    cmd = "dig @#{@host} #{domain} +norec"
    result = `#{cmd}`
    line = result.grep(/ANSWER: \d+,/)
    line[0] =~ /ANSWER: (\d+),/
    if $1 == "0"
      print "#{@host} NG\n"
    else
      print "#{@host} OK\n"
    end
  end
end

if ARGV.size != 1
  print "USAGE: #{$0} example.com\n"
  exit
end

domain  = ARGV[0]

DNS.new("ns1.example.com").check(domain)
DNS.new("ns2.example.com").check(domain)
