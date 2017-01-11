#
# Cookbook Name:: moodle
# Recipe:: default
#
# Copyright 2017, Moodlerooms, Inc.
#
# All rights reserved - Do Not Redistribute
#

# Add this so we can install PHP7.1.
apt_repository 'ondrej-php' do
  uri 'ppa:ondrej/php'
  distribution 'xenial'
end