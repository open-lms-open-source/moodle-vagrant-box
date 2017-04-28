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