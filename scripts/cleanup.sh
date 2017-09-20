#!/bin/sh -eux

# Source: https://github.com/chef/bento/blob/master/scripts/ubuntu/cleanup.sh
# Removed a lot of the cleanup because it didn't actually do anything.

# Clean packages.
apt-get -y clean;

# Remove docs.
rm -rf /usr/share/doc/*

# Remove caches.
find /var/cache -type f -exec rm -rf {} \;

# Delete any logs that have built up during the install/
find /var/log/ -name *.log ! -name php_errors.log -exec rm -f {} \;
