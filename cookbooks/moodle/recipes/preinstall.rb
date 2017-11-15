#
# Cookbook Name:: moodle
# Recipe:: default
#
# Copyright 2017 Blackboard Inc. (http://www.blackboard.com)

# Add this so we can install PHP7.1.
apt_repository 'ondrej-php' do
  uri 'ppa:ondrej/php'
  distribution 'xenial'
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
