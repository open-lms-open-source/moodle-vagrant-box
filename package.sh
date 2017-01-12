#!/usr/bin/env bash
set -e

# Remove previously created box.
if [ -f package.box ]; then
    rm package.box
    echo "Deleted package.box"
fi

set -x

vagrant destroy
vagrant up
vagrant ssh -c "sudo /vagrant/scripts/cleanup.sh"
vagrant ssh -c "sudo /vagrant/scripts/minimize.sh"
vagrant package

# Print the size of the box.
du -sh package.box