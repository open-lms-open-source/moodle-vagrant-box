# Introduction

This project is used to provision a base box that can be used for Moodle development.

# Setup

Confirm VirtualBox version at the [Bento project](https://github.com/chef/bento).

1. Install the [Chef Development Kit](https://downloads.chef.io/chef-dk/)
2. Install Vagrant from [vagrantup.com](http://vagrantup.com).  The recommended and tested version is `1.8.4`.
3. Install VirtualBox from [virtualbox.org](http://virtualbox.org).  The recommended and tested version is `5.0.26`.
4. Install Vagrant Plugins: `vagrant plugin install vagrant-hostmanager vagrant-berkshelf`
5. Open your terminal and from within this project, run: `vagrant up`

# Package

1. Run `./package.sh`
2. Upload the resulting `package.box` to Atlas.
3. Tag the repository with the same version number used in Atlas.

Example tag:

    $ git tag -a 1.0.0 -m "Release version 1.0.0"
    $ git push origin 1.0.0

# Helpful links

https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04
https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04?utm_source=legacy_reroute
https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04
https://help.ubuntu.com/community/LinuxFilesystemTreeOverview
https://docs.moodle.org/31/en/Nginx
https://scotch.io/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one