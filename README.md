# Introduction

This project is used to provision a base box that can be used for Moodle development.  This
base box is built upon the boxes published by the [Bento project](https://github.com/chef/bento).

This box is published to [Vagrant Cloud](https://app.vagrantup.com/open-lms-open-source).  You can
use this box with Vagrant like any other box that's published on Atlas.

The rest of this document is geared towards building this box, not how to use it.  So likely
you do not need to read any further.

# Setup

1. Install the [Chef Development Kit](https://downloads.chef.io/chef-dk/).
2. Install recommended versions of Vagrant and VirtualBox for the [latest box release on Vagrant Cloud](https://app.vagrantup.com/open-lms-open-source/boxes/ubuntu-16.04-moodle-dev).
3. Install Vagrant Plugins: `vagrant plugin install vagrant-hostmanager vagrant-berkshelf`
4. To build the box, open your terminal and from within this project, run: `vagrant up`

# Package

1. Run `make` (or `make clean && make`)
2. Upload the resulting `package.box` to [Vagrant Cloud](https://app.vagrantup.com/open-lms-open-source).
3. Tag the repository with the same version number used in Atlas.

Tag format `{OS Version}-{Box Version}`, EG:

    $ git tag -a 18.04-1.0.0 -m "Ubuntu 18.04 box version 1.0.0"
    $ git push origin 18.04-1.0.0

# Update cookbooks

1. Update versions in `Berksfile`.
2. Run `berks update` which will update the `Berksfile.lock`.

# Update base box

Look for new versions of the base box on [Vagrant Cloud](https://app.vagrantup.com/bento/boxes/ubuntu-18.04).
Note that in the version description, there is a dump about the versions of VirtualBox and Vagrant that
were used to build the box.  We should match those versions.

To get the new base box:

    $ vagrant box update
    $ vagrant box prune

Then rebuild the box.

# Helpful links

* [Create self signed certificate](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04)
* [LEMP](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04)
* [Nginx](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04)
* [Moodle Nginx](https://docs.moodle.org/31/en/Nginx)
* [Filesystem](https://help.ubuntu.com/community/LinuxFilesystemTreeOverview)
* [Tutorial on making base box](https://scotch.io/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one)
