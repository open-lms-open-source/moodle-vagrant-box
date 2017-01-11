# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Latest Ubuntu 16.04 box
  config.vm.box = "bento/ubuntu-16.04"

  # Host manager plugin settings.  This updates /etc/hosts on guest and host.
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.aliases = %w(moodle.dev webgrind.dev core-moodle.dev)
  
  # Berkshelf plugin settings.
  config.berkshelf.enabled = true

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.

  # Forward port for MySQL
  config.vm.network "forwarded_port", guest: 3306, host: 3306

  # Forward port for PostgreSQL
  config.vm.network "forwarded_port", guest: 5432, host: 5432

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.100.100"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.

  # Mount current directory to the /vagrant directory in the VM
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "8192"]
    vb.customize ["modifyvm", :id, "--name", "moodle-vagrant-box"]
  end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision "chef_solo" do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  # end

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe 'moodle::preinstall'
    chef.add_recipe 'apt'
    chef.add_recipe 'build-essential'
    chef.add_recipe 'postgresql::server'
    chef.add_recipe 'openssl::upgrade'
    chef.add_recipe 'php'
    chef.add_recipe 'redisio'
    chef.add_recipe 'redisio::enable'
    chef.add_recipe 'git'
    chef.add_recipe 'moodle'
    chef.json = {
      :php => {
        :version          => '7.1.0',
        :conf_dir         => '/etc/php/7.1/cli',
        :packages         => %w(php7.1-cgi php7.1 php7.1-dev php7.1-cli),
        :fpm_package      => 'php7.1-fpm',
        :fpm_pooldir      => '/etc/php/7.1/fpm/pool.d',
        :fpm_service      => 'php7.1-fpm',
        :fpm_socket       => '/var/run/php/php7.1-fpm.sock',
        :fpm_default_conf => '/etc/php/7.1/fpm/pool.d/www.conf',
        :ext_conf_dir     => '/etc/php/7.1/mods-available',
      },
      :postgresql => {
        :config   => {
          :listen_addresses => "*",
        },
        :pg_hba   => [
          { type: 'local', db: 'all', user: 'postgres', addr: nil, method: 'trust' },
          { type: 'local', db: 'all', user: 'all', addr: nil, method: 'ident' },
          { type: 'host', db: 'all', user: 'all', addr: '0.0.0.0/0', method: 'md5' },
          { type: 'host', db: 'all', user: 'all', addr: '127.0.0.1/32', method: 'md5' },
          { type: 'host', db: 'all', user: 'all', addr: '::1/128', method: 'md5' }
        ],
        :password => {
          :postgres => "root"
        }
      }
    }
  end
end
