# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Latest Ubuntu 16.04 box.
  config.vm.box = "bento/ubuntu-16.04"

  # Host manager plugin settings.  This updates /etc/hosts on guest and host.
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.aliases = %w(moodle.test webgrind.test core-moodle.test)
  
  # Berkshelf plugin settings.
  config.berkshelf.enabled = true

  # Forward port for MySQL.
  config.vm.network "forwarded_port", guest: 3306, host: 3306

  # Forward port for PostgreSQL.
  config.vm.network "forwarded_port", guest: 5432, host: 5432

  # Create a private network, which allows host-only access to the machine using a specific IP.
  config.vm.network "private_network", ip: "192.168.100.100"

  # Mount current directory to the /vagrant directory in the VM.
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "8192"]
    vb.customize ["modifyvm", :id, "--name", "moodle-vagrant-box"]
  end

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe 'moodle::preinstall'
    chef.add_recipe 'apt'
    chef.add_recipe 'build-essential'
    chef.add_recipe 'runit'
    chef.add_recipe 'postgresql::server'
    chef.add_recipe 'openssl::upgrade'
    chef.add_recipe 'php'
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
