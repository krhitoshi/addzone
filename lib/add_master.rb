
require 'add_zone'

class AddMaster < AddZone
  attr_accessor :spf_include, :bind_user, :bind_group
  attr_reader :host_names, :email, :ip_address

  def initialize(addzone_conf = nil)
    super(addzone_conf)
    raise "host_names should be more than two" unless @host_names.size >= 2
    @spf_include = nil
    @bind_user = @bind_group = "named"
  end
  def type
    "master"
  end
  def condition_check
    super
    zone_backup_dir_check
  end
  def create_zone_file(domain)
    zone_dir_check
    raise "Already Exist Zone File: " + zone_file_path(domain) if zone_file_exist?(domain)
    File::open(zone_file_path(domain), "w"){|f|
      f.puts zone(domain)
    }
    FileUtils.chown bind_user, bind_group, zone_file_path(domain)
    zone_file_path(domain)
  end
  def delete_zone_file(domain)
    zone_file_check(domain)
    File.delete zone_file_path(domain)
    zone_file_path(domain)
  end
  def email=(address)
    @email = address.gsub(/@/, '.')
  end
  def serial
    Time.now.strftime("%Y%m%d") + "01"
  end
  def zone_conf(domain)
    zone_header(domain) + "\n" + zone_footer(domain) + "\n"
  end
  def zone_SOA
    "@       IN SOA #{@host_names[0]}. #{email}.("
  end
  def zone_NS
    ns_records = []
    @host_names.each do |name|
      ns_records << "        IN NS    #{name}."
    end
    ns_records.join("\n")
  end
  def zone_TXT
    if @spf_include
      %Q!        IN TXT   "v=spf1 mx include:#{@spf_include} ~all"!
    else
      %Q!        IN TXT   "v=spf1 mx ~all"!
    end
  end
  def zone(domain)
    zone = <<EOS
$TTL    600
#{zone_SOA}
        #{serial}  ; Serial
        10800       ; Refresh
        3600        ; Retry
        604800      ; Expire
        600 )       ; Minimum
#{zone_NS}
#{zone_TXT}
        IN MX 10 mail
        IN A     #{@ip_address}
www     IN A     #{@ip_address}
mail    IN A     #{@ip_address}
ftp     IN CNAME www
pop     IN CNAME mail
smtp    IN CNAME mail
EOS
    zone
  end

  private
  def load_addzone_conf
    yaml = super['addmaster']
    @ip_address = yaml['ip_address']
    @host_names = yaml['name_servers']
    @email = yaml['email'].gsub(/@/, '.')
  end
end
