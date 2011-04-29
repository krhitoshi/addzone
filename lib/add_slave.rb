
require 'common'
require 'add_zone'
test_init

class AddSlave < AddZone
  attr_reader :master_ip

  def initialize(master_ip)
    super()
    @master_ip = master_ip
  end
  def type
    "slave"
  end
  def zone_conf(domain)
    conf = <<EOS
#{zone_header(domain)}
      masters { #{@master_ip}; };
#{zone_footer(domain)}
EOS
    conf
  end
end
