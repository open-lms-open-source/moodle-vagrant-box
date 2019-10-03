#
# Cookbook Name:: moodle
# Recipe:: default
#
# Copyright 2017 Blackboard Inc. (http://www.blackboard.com)

# Install latest version of git.
apt_repository 'git-core-ppa' do
  uri 'ppa:git-core/ppa'
  distribution 'bionic'
end

apt_repository 'google-chrome' do
  arch 'amd64'
  uri 'http://dl.google.com/linux/chrome/deb'
  distribution 'stable'
  components %w(main)
  key 'https://dl-ssl.google.com/linux/linux_signing_key.pub'
end

# This is so NodeJS 8.9.X is install via apt-get.
execute "Setup NodeJS 8" do
  command "curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -"
  not_if "which nodejs"
end
