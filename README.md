# Introduction

This project is used to provision a base box that can be used for Moodle development.

# Setup

Confirm VirtualBox version at the [Bento project](https://github.com/chef/bento).

1. Install the [Chef Development Kit](https://downloads.chef.io/chef-dk/)
2. Install Vagrant from [vagrantup.com](http://vagrantup.com).  The recommended and tested version is `1.8.6`.
3. Install VirtualBox from [virtualbox.org](http://virtualbox.org).  The recommended and tested version is `5.1.6`.
4. Install Vagrant Plugins: `vagrant plugin install vagrant-hostmanager vagrant-berkshelf`
5. Open your terminal and from within this project, run: `vagrant up`

# Package

1. Run `./package.sh`
2. Upload the resulting `package.box` to [Atlas](https://atlas.hashicorp.com/moodlerooms).
3. Tag the repository with the same version number used in Atlas.

Tag format `{OS Version}-{Box Version}`, EG:

    $ git tag -a 16.04-1.0.0 -m "Ubuntu 16.04 box version 1.0.0"
    $ git push origin 16.04-1.0.0

# Update cookbooks

1. Update versions in `Berksfile`.
2. Run `berks update` which will update the `Berksfile.lock`.

# Helpful links

* [Create self signed certificate](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04)
* [LEMP](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04)
* [Nginx](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04)
* [Moodle Nginx](https://docs.moodle.org/31/en/Nginx)
* [Filesystem](https://help.ubuntu.com/community/LinuxFilesystemTreeOverview)
* [Tutorial on making base box](https://scotch.io/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one)
