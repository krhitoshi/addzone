
require 'fileutils'

class AddZone
  attr_accessor :conf_file_dir, :conf_file_name, :zone_dir, :zone_base

  def initialize
    chroot_dir = "/var/named/chroot"
    @conf_file_name = "hosting.conf"
    @conf_file_dir = File.join [chroot_dir , "etc"]
    @zone_dir = File.join [chroot_dir , "var", "named", type]
    @zone_base = type
  end
  def condition_check
    conf_file_check
    conf_backup_dir_check
  end
  def conf_file_dir_check
    unless conf_file_dir_exist?
      raise "Configure Direcotry Not Found: " + conf_file_dir
    end
  end
  def conf_file_check
    conf_file_dir_check
    unless conf_file_exist?
      raise "Configure File Not Found: " + conf_file_path
    end
  end
  def conf_backup_dir_check
    unless conf_backup_dir_exist?
      raise "Configure Backup Directory Not Found: " + conf_backup_dir
    end
  end
  def backup_conf_file
    conf_backup_dir_check
    FileUtils.copy_file(conf_file_path, conf_backup_file_path, true)
    conf_backup_file_path
  end
  def zone_dir_check
    unless zone_dir_exist?
      raise "Zone Directory Not Found: " + zone_dir
    end
  end
  def zone_backup_dir_check
    zone_dir_check
    unless zone_backup_dir_exist?
      raise "Zone Backup Directory Not Found: " + zone_backup_dir
    end
  end
  def zone_file_check(domain)
    zone_dir_check
    unless zone_file_exist?(domain)
      raise "Zone File Not Found: " + zone_file_path(domain)
    end
  end
  def zone_check(domain)
    conf_file_check
    if zone_exist?(domain)
      raise "Already Registered Zone: " + domain
    end
  end
  def type
    "base"
  end
  def backup_dir(base)
    File.join [base, "backup"]
  end
  def conf_backup_dir
    backup_dir(@conf_file_dir)
  end
  def zone_backup_dir
    backup_dir(@zone_dir)
  end
  def zone_backup_dir_exist?
    File.exist?(zone_backup_dir)
  end
  def conf_file_dir_exist?
    File.exist?(conf_file_dir)
  end
  def conf_file_path
    File.join [conf_file_dir, @conf_file_name]
  end
  def conf_file_exist?
    File.exist?(conf_file_path)
  end
  def conf_backup_dir_exist?
    File.exist?(conf_backup_dir)
  end
  def str_time
    Time.now.strftime("%Y%m%d%H%M")
  end
  def conf_backup_file_path
    File.join [conf_backup_dir, @conf_file_name + "." + str_time]
  end
  def zone_exist?(domain)
    open(conf_file_path).each do |line|
      return true if line =~ /zone\s+"#{domain}"/
    end
    false
  end
  def zone_dir_exist?
    File.exist?(zone_dir)
  end
  def zone_file_name(domain)
    domain + ".zone"
  end
  def zone_file_path(domain)
    File.join [zone_dir, zone_file_name(domain)]
  end
  def base_zone_file_path(domain)
    File.join [zone_base, zone_file_name(domain)]
  end
  def zone_file_exist?(domain)
    File.exist?(zone_file_path(domain))
  end
  def add_zone_conf(domain)
    zone_check(domain)
    open(conf_file_path, "a"){|f|
      f.puts "\n" + zone_conf(domain)
    }
    domain
  end
  def zone_header(domain)
    header = <<EOS
// #{domain} : #{str_time}
zone "#{domain}" {
      type #{type};
EOS
    header.chomp
  end
  def zone_footer(domain)
    footer = <<EOS
      file "#{base_zone_file_path(domain)}";
};
EOS
    footer.chomp
  end
end

class AddMaster < AddZone
  attr_accessor :spf_include, :bind_user, :bind_group
  attr_reader :host_names, :email, :ip_address

  def initialize(host_names, ip_address)
    raise "host_names should be Array" unless host_names.kind_of? Array
    raise "host_names should be more than two" unless host_names.size >= 2
    super()
    @host_names, @ip_address = host_names, ip_address
    @email = "root." + @host_names[0]
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
end

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
