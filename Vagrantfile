# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.9.0"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with box details
if File.exist?("config.yaml")
  configuration = YAML.load_file("config.yaml")
else
  raise Vagrant::Errors::VagrantError.new, "Configuration file not found!"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  # Set server to Ubuntu 14.04
  config.vm.box = "ubuntu/trusty64"

  # Provider-specific configuration so you can fine-tune various backing providers
  # for Vagrant. These expose provider-specific options.
  # If using VirtualBox:
  config.vm.provider "virtualbox" do |v|
    # GUI vs. Headless
    v.gui = configuration["virtualbox"]["gui"]

    # Virtual Machine Name
    v.name = configuration["name"]

    # Set server cpus
    v.customize ["modifyvm", :id, "--cpus", configuration["virtualbox"]["cpus"]]

    # Set server memory
    v.customize ["modifyvm", :id, "--memory", configuration["virtualbox"]["memory"]]

    # Allow symlinks
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]

    # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
    # If the clock gets more than 15 minutes out of sync (due to your laptop going
    # to sleep for instance, then some 3rd party services will reject requests.
    v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]

    # Prevent VMs running on Ubuntu to lose internet connection
    # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    # v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # Disable automatic box update checking. If you disable this, then boxes will
  # only be checked for updates when the user runs `vagrant box outdated`. This
  # is not recommended.
  # config.vm.box_check_update = false

  # SSH Agent Forwarding
  # Enable agent forwarding on `vagrant ssh` commands. This allows you to use ssh
  # keys on your host machine inside the guest.
  # config.ssh.forward_agent = true

  # Set the timezone
  if Vagrant.has_plugin?("vagrant-timezone")
    config.timezone.value = configuration["timezone"]
  end

  # Setup virtual hostname
  config.vm.hostname = configuration["hostname"]

  # Public Network
  # Using a public network rather than the default private network configuration
  # will allow access to the guest machine from other devices on the network. By
  # default, enabling this line will cause the guest machine to use DHCP to
  # determine its IP address. You will also be prompted to choose a network
  # interface to bridge with during `vagrant up`.
  # config.vm.network :public_network

  # Set a local private network IP address.
  # See http://en.wikipedia.org/wiki/Private_network for explanation.
  # Create a private network, which allows host-only access to the machine using
  # a specific IP.
  # You can use the following IP ranges:
  #   10.0.0.1    - 10.255.255.254
  #   172.16.0.1  - 172.31.255.254
  #   192.168.0.1 - 192.168.255.254
  config.vm.network :private_network, ip: configuration["ip"]

  # Configure Hosts Manager
  if Vagrant.has_plugin?('vagrant-hostmanager')
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    config.hostmanager.aliases = configuration["aliases"]
  else
    raise Vagrant::Errors::VagrantError.new,
      "Required plugin vagrant-hostmanager is not installed!\n" +
      "Install with \"vagrant plugin install vagrant-hostmanager\""
  end

  # Add port-forward for Nginx
  config.vm.network "forwarded_port", guest: 80, host: 80
  config.vm.network "forwarded_port", guest: 443, host: 443

  # Add port-forward for MailDev
  config.vm.network "forwarded_port", guest: 1025, host: 1025 # SMTP port to catch emails
  config.vm.network "forwarded_port", guest: 1080, host: 1080 # Web interface

  # Add port-forward for Node.js Inspector
  config.vm.network "forwarded_port", guest: 9229, host: 9229

  # Add port-forward for MongoDB
  config.vm.network "forwarded_port", guest: 27017, host: 27017

  # Fix for tty warnings while provisioning Ubuntu.
  # See: http://foo-o-rama.com/vagrant--stdin-is-not-a-tty--fix.html
  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # Install system requirements
  if File.exist?("./scripts/provision.sh")
    config.vm.provision :shell, :path => "./scripts/provision.sh", :args => [
      configuration["hostname"],
      configuration["appPort"],
      configuration["mongodb"]["user"],
      configuration["mongodb"]["password"]
    ]
  end

  # Run startup.sh at every startup
  if File.exist?("./scripts/startup.sh")
    config.vm.provision :shell, :path => "./scripts/startup.sh", run: "always"
  end

  # Share an additional folder to the guest VM. The first argument is the path
  # on the host to the actual folder. The second argument is the path on the
  # guest to mount the folder. And the optional third argument is a set of
  # non-required options.
  config.vm.synced_folder "./app", "/home/vagrant/app", create: true, group: "vagrant", owner: "vagrant"
end