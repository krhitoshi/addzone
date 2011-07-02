require 'fileutils'
require 'yaml'

class AddZone
  attr_accessor :conf_file_name, :zone_dir, :zone_base
  attr_reader :addzone_conf, :root_dir

  def initialize(addzone_conf = nil)
    addzone_conf ? @addzone_conf = addzone_conf : @addzone_conf = "/etc/addzone.conf"
    load_addzone_conf
    @conf_file_dir = File.join [root_dir , "etc"]
    @zone_dir = File.join [root_dir , "var", "named", type]
    @zone_base = type
  end
  def condition_check
    conf_file_check
    conf_backup_dir_check
  end
  def conf_file_dir_check
    unless conf_file_dir_exist?
      raise "Configure Direcotry Not Found: " + @conf_file_dir
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
    File.directory?(zone_backup_dir)
  end
  def conf_file_dir_exist?
    File.directory?(@conf_file_dir)
  end
  def conf_file_path
    File.join [@conf_file_dir, @conf_file_name]
  end
  def conf_file_exist?
    File.exist?(conf_file_path)
  end
  def conf_backup_dir_exist?
    File.directory?(conf_backup_dir)
  end
  def str_time
    Time.now.strftime("%Y%m%d%H%M%S")
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
    File.directory?(zone_dir)
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

  private
  def load_addzone_conf
    addzone_conf_check
    yaml = YAML.load_file(@addzone_conf)
    @root_dir = yaml['base']['root_dir']
    @conf_file_dir = yaml['base']['conf_file_dir']
    @conf_file_name = yaml['base']['conf_file_name']
    yaml
  end
  def addzone_conf_check
    unless File.exist? @addzone_conf
      raise "Configure File of AddMaster or AddSlave Not Foud: " + @addzone_conf
    end
  end
end
