#
# Cookbook Name:: moodle
# Recipe:: default
#
# Copyright 2017 Open LMS. (https://www.openlms.net)

# Add this so we can install PHP 7.4.
apt_repository 'ondrej-php' do
  uri 'ppa:ondrej/php'
  distribution 'bionic'
end

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

# This is so NodeJS 14.X is install via apt-get.
execute "Setup NodeJS 14" do
  command "curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -"
  not_if "which nodejs"
end
