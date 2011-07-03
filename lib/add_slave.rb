
require 'add_zone'

class AddSlave < AddZone
  attr_reader :master_ip

  def initialize(addzone_conf = nil)
    super(addzone_conf)
  end
  def master_ip=(ip_address)
    @master_ip = ip_address
  end
  def add_zone(domain)
    backup_conf_file
    add_zone_conf(domain)
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
    yaml = super['addslave']
    @master_ip = yaml['master_ip']
    @zone_dir = yaml['zone_dir']
  end
  def type
    "slave"
  end
end
