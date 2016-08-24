require 'addzone/version'

require 'addzone/base'

module AddZone
  DEFAULT_ADDZONE_CONF_PATH = "/etc/addzone.conf"

  def self.check_dns(server, domain)
    result = `dig @#{server} #{domain} +norec`
    line = result.lines.grep(/ANSWER: \d+,/)
    line[0] =~ /ANSWER: (\d+),/
    if $1 == "0"
      puts "#{server} NG"
    else
      puts "#{server} OK"
    end
  end
end
