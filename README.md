# Introduction

This project is used to provision a base box that can be used for Moodle development.

# Setup

1. Install the [Chef Development Kit](https://downloads.chef.io/chef-dk/)
2. Install Vagrant from [vagrantup.com](http://vagrantup.com).  The recommended and tested version is `1.8.4`.
3. Install VirtualBox from [virtualbox.org](http://virtualbox.org).  The recommended and tested version is `5.0.16`.
4. Install Vagrant Plugins: `vagrant plugin install vagrant-vbguest vagrant-hostmanager vagrant-berkshelf`
5. Open your terminal and from within this project, run: `vagrant up`

# Helpful links

https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04
https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04?utm_source=legacy_reroute