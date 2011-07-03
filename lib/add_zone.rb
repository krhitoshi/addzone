require 'fileutils'
require 'yaml'

class AddZone
  attr_reader :addzone_conf

  class ConfigureError < StandardError; end

  def initialize(addzone_conf = nil)
    if addzone_conf
      @addzone_conf = addzone_conf
    else
      @addzone_conf = "/etc/addzone.conf"
    end

    load_addzone_conf
    @zone_base = type
    condition_check
  end
  def delete_zone(domain)
    delete_zone_conf(domain)
    backup_zone_file(domain)
  end
  def backup_zone_file(domain)
    FileUtils.mv zone_file_path(domain), zone_backup_dir
    File.join [zone_backup_dir, zone_file_name(domain)]
  end
  def delete_zone_file(domain)
    zone_file_check(domain)
    File.delete zone_file_path(domain)
    zone_file_path(domain)
  end
  def add_zone_check(domain)
    conf_file_check
    if zone_exist?(domain)
      raise ConfigureError, "Already Registered Zone: " + domain
    end
  end
  def delete_zone_check(domain)
    conf_file_check
    unless zone_exist?(domain)
      raise ConfigureError, "Not Registered Zone: " + domain
    end
  end
  def add_zone_conf(domain)
    add_zone_check(domain)
    open(conf_file_path, "a"){|f|
      f.puts zone_conf(domain)
    }
    domain
  end
  def delete_zone_conf(domain)
    delete_zone_check(domain)
    flag = false
    end_flag = false
    backup = backup_conf_file
    text = ""
    open(conf_file_path,"w") do |wf|
      open(backup).each do |line|
        if line =~ /\/\/ #{domain} :/
          flag = true
        elsif !flag && line =~ /zone "#{domain}" \{/
          flag = true
        elsif flag && line =~ /\};/ && line !~ /\{/
          text += line
          end_flag = true
          flag = false
          next
        elsif end_flag
          end_flag = false
          if line =~ /^\s*$/
            text += line
            next
          end
        end
        text += line if flag
        wf.write line unless flag
      end
    end
    text
  end

  private
  def load_addzone_conf
    addzone_conf_check
    yaml = YAML.load_file(@addzone_conf)
    @conf_file_dir = yaml['base']['conf_file_dir']
    @conf_file_name = yaml['base']['conf_file_name']
    @zone_dir = type
    yaml
  end
  def addzone_conf_check
    unless File.exist? @addzone_conf
      raise "Configure File of AddMaster or AddSlave Not Foud: " + @addzone_conf
    end
  end
  def zone_dir_check
    unless zone_dir_exist?
      raise "Zone Directory Not Found: " + @zone_dir
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
  def zone_backup_dir_exist?
    File.directory?(zone_backup_dir)
  end
  def conf_file_dir_exist?
    File.directory?(@conf_file_dir)
  end
  def conf_file_exist?
    File.exist?(conf_file_path)
  end
  def conf_backup_dir_exist?
    File.directory?(conf_backup_dir)
  end
  def zone_exist?(domain)
    open(conf_file_path).each do |line|
      return true if line =~ /zone\s+"#{domain}"/
    end
    false
  end
  def zone_dir_exist?
    File.directory?(@zone_dir)
  end
  def backup_conf_file
    conf_backup_dir_check
    FileUtils.copy_file(conf_file_path, conf_backup_file_path, true)
    conf_backup_file_path
  end
  def type
    "base"
  end
  def str_time
    Time.now.strftime("%Y%m%d%H%M%S")
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
  def conf_backup_file_path
    File.join [conf_backup_dir, @conf_file_name + "." + str_time]
  end
  def zone_file_name(domain)
    domain + ".zone"
  end
  def zone_file_path(domain)
    File.join [@zone_dir, zone_file_name(domain)]
  end
  def base_zone_file_path(domain)
    File.join [@zone_base, zone_file_name(domain)]
  end
  def zone_file_exist?(domain)
    File.exist?(zone_file_path(domain))
  end
  def conf_file_path
    File.join [@conf_file_dir, @conf_file_name]
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
  def condition_check
    conf_file_check
    conf_backup_dir_check
  end
end
