
def test_init
  Dir.chdir File.dirname(__FILE__)
  File.delete "data/etc/hosting.conf" if File.exist?("data/etc/hosting.conf")
  FileUtils.copy_file "data/etc/hosting.conf.dist", "data/etc/hosting.conf", true
end

class Time
  def Time.now
    local(2011,4,25,15,00)
  end
end
