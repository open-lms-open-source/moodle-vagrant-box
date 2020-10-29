#
# Cookbook Name:: moodle
# Recipe:: default
#
# Copyright 2017 Open LMS. (https://www.openlms.net)

# Install latest version of git.
apt_repository 'git-core-ppa' do
  uri 'ppa:git-core/ppa'
  distribution 'focal'
end

apt_repository 'google-chrome' do
  arch 'amd64'
  uri 'http://dl.google.com/linux/chrome/deb'
  distribution 'stable'
  components %w(main)
  key 'https://dl-ssl.google.com/linux/linux_signing_key.pub'
end

# This is so NodeJS 14.0.X is install via apt-get.
execute "Setup NodeJS 14.0" do
  command "curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -"
  not_if "which nodejs"
end
