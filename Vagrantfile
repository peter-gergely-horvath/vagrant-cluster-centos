# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

# Defaults for config options defined in CONFIG
$num_instances = 3
$instance_name_prefix = "hadoop"
$enable_serial_logging = false
$share_home = false
$vm_gui = false
$vm_memory = 8192
$vm_cpus = 1
$forwarded_ports = {}

$script = <<-SCRIPT

echo Disabling the firewall
sudo systemctl disable firewalld
sudo systemctl stop firewalld

echo Disabling SELinux
sudo setenforce 0
sudo sed -i 's/SELINUX=\(enforcing\|permissive\)/SELINUX=disabled/g' /etc/selinux/config

echo Installing NTPD
sudo yum install ntp ntpdate ntp-doc
sudo echo "server 0.pool.ntp.org" >> /etc/ntp.conf
sudo echo "server 1.pool.ntp.org" >> /etc/ntp.conf
sudo echo "server 3.pool.ntp.org" >> /etc/ntp.conf

echo Starting NTPD
sudo systemctl enable ntpd
sudo systemctl start ntpd

echo Synchronizing the system clock to the NTP server
sudo ntpdate -u server

echo Synchronizing the hardware clock to the system clock
sudo hwclock --systohc
SCRIPT

# Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV["NUM_INSTANCES"].to_i > 0 && ENV["NUM_INSTANCES"]
  $num_instances = ENV["NUM_INSTANCES"].to_i
end

# Use old vb_xxx config variables when set
def vm_gui
  $vb_gui.nil? ? $vm_gui : $vb_gui
end

def vm_memory
  $vb_memory.nil? ? $vm_memory : $vb_memory
end

def vm_cpus
  $vb_cpus.nil? ? $vm_cpus : $vb_cpus
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false


  config.vm.box = "centos/8"
  config.vm.provision "shell", inline: $script
  config.vagrant.plugins = [ "vagrant-hostmanager" ]

  # enable hostmanager
  config.hostmanager.enabled = true

  # configure the host's /etc/hosts
  config.hostmanager.manage_host = true

  (1..$num_instances).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$instance_name_prefix, i] do |config|
      config.vm.hostname = vm_name

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      # foward Docker registry port to host for node 01
      if i == 1
        config.vm.network :forwarded_port, guest: 5000, host: 5000
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = vm_gui
        vb.memory = vm_memory
        vb.cpus = vm_cpus
      end

      ip = "172.17.11.#{i+100}"
      config.vm.network :private_network, ip: ip

    end
  end
end
