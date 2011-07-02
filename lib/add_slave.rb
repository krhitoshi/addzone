
require 'add_zone'

class AddSlave < AddZone
  attr_reader :master_ip

  def initialize(addzone_conf = nil)
    super(addzone_conf)
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
  
  private
  def load_addzone_conf
    @master_ip = super['addslave']['master_ip']
  end
end
