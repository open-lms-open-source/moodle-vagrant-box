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
# From https://scotch.io/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one#make-the-box-as-small-as-possible
vagrant ssh -c "sudo apt-get clean && sudo dd if=/dev/zero of=/EMPTY bs=1M || true && sudo rm -f /EMPTY && cat /dev/null > ~/.bash_history && history -c && exit"
vagrant package
