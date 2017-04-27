#
# Cookbook Name:: moodle
# Recipe:: default
#
# Copyright 2014, Moodlerooms, Inc.
#
# All rights reserved - Do Not Redistribute
#

##########################
###  INSTALL PACKAGES  ###
##########################

node['moodle']['packages'].each do |pkg|
  package pkg do
    action :install
  end
end

########################
###  INSTALL NGINX  ###
########################

# Create self signed certificate for SSL support.
openssl_x509 '/etc/ssl/certs/nginx-selfsigned.crt' do
  common_name 'moodle.dev'
  org 'Blackboard'
  org_unit 'Moodlerooms'
  country 'US'
end

# Create dhparam for SSL support.
openssl_dhparam '/etc/ssl/certs/dhparam.pem' do
  key_length 2048
end

# Copy over self signed Nginx snippet, tells Nginx where to find the certificate.
cookbook_file "/etc/nginx/snippets/self-signed.conf" do
  source "self-signed.conf"
  owner "root"
  group "root"
  mode 0644
end

# Copy over SSL params Nginx snippet.
cookbook_file "/etc/nginx/snippets/ssl-params.conf" do
  source "ssl-params.conf"
  owner "root"
  group "root"
  mode 0644
end

# Run Nginx as our user.
ruby_block "Change nginx user" do
  block do
    file = Chef::Util::FileEdit.new("/etc/nginx/nginx.conf")
    file.search_file_replace_line(/user www-data;/,"user "+node['moodle']['user']+";")
    file.write_file
  end
end

# Install php-fpm.
php_fpm_pool "default" do
  action :install
  user "vagrant"
  group "vagrant"
  listen_user "vagrant"
  listen_group "vagrant"
end

#######################
###  INSTALL MYSQL  ###
#######################

# This configures MySQL and is from the mysql cookbook.
mysql_service 'default' do
  version '5.7'
  port '3306'
  bind_address '0.0.0.0'
  initial_root_password 'root'
  action [:create, :start]
end

# Add extra MySQL configs to run Moodle.
cookbook_file "/etc/mysql/conf.d/moodle.cnf" do
  source "mysql.cnf"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, 'mysql_service[default]'
end

# This makes SQL accessible from the outside for MySQL clients, etc.
execute "Grant SQL" do
  command "mysql -u root --password=root -h 127.0.0.1 -e \"GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;\""
end

#######################
###  CONFIGURE PHP  ###
#######################

# Add custom PHP ini settings.
template "/etc/php/7.1/mods-available/moodle.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode 0644
  variables (node['moodle']['php']['ini'])
end

# Enable custom PHP ini settings.
execute "phpenmod moodle" do
  command "sudo /usr/sbin/phpenmod moodle"
end

# Install PHP specific packages.
node['moodle']['php']['packages'].each do |pkg|
  package pkg do
    action :install
  end

  # Ensure the extension is enabled.
  extensionName = pkg.gsub("php-", "")
  execute "phpenmod " + extensionName do
    command "sudo /usr/sbin/phpenmod " + extensionName
  end
end

# Create an error log for PHP.
file "/var/log/php_errors.log" do
  owner "vagrant"
  group "vagrant"
  action :touch
  mode 0666
end

directory '/srv/xdebug-profiles' do
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0777
end

#####################
###  MOODLE SITE  ###
#####################

# Create default site for Moodle.  Allow for customization by not overriding.
template "/etc/nginx/sites-enabled/moodle" do
  source "server.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
    :server_name => 'moodle.dev *.vagrantshare.com',
    :docroot => '/vagrant/www/moodle'
  })
end

# Ensure moodledata directory exists in the srv directory.
directory '/srv/moodledata' do
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0777
end

##########################
###  CORE MOODLE SITE  ###
##########################

# Create site for core moodle.
template "/etc/nginx/sites-enabled/core-moodle" do
  source "server.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
    :server_name => 'core-moodle.dev',
    :docroot => '/vagrant/www/core-moodle'
  })
end

##################
###  WEBGRIND  ###
##################

# Grab the webgrind code.
git '/var/www/webgrind' do
  repository "https://github.com/jokkedk/webgrind.git"
  revision "master" # Use master until something newer than v1.4.0 is released.
end

# Compile the preprocessor to improve performance.
execute "make webgrind" do
  command "make clean && make"
  cwd '/var/www/webgrind'
end

# Create site for webgrind.
template "/etc/nginx/sites-enabled/webgrind" do
  source "server.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
    :server_name => 'webgrind.dev',
    :docroot => '/var/www/webgrind'
  })
end

# Webgrind looks to /usr/local/bin/dot for dot.
link "/usr/local/bin/dot" do
  to "/usr/bin/dot"
end

#################
###  PHPUnit  ###
#################

# This may also be required for Behat, not sure.
# This is an obscure requirement to run PHPUnit tests, see MDL-50687.
execute "install locale en_AU.UTF-8" do
  command "sudo locale-gen en_AU.UTF-8"
end

###############
###  BEHAT  ###
###############

# Download Selenium Server.
# WARNING: If Selenium file name is updated, also update files/default/behat-servers-start.sh
remote_file '/usr/local/bin/selenium-server-standalone-2.53.1.jar' do
  source 'http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar'
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0755
end

# Copy in behat-servers-start command.
cookbook_file "/usr/local/bin/behat-servers-start" do
  source "behat-servers-start.sh"
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0777
end

# Copy in behat-servers-stop command.
cookbook_file "/usr/local/bin/behat-servers-stop" do
  source "behat-servers-stop.sh"
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0777
end

#####################
###  NPM Modules  ###
#####################

# Install NPM packages.
node['moodle']['npm']['packages'].each do |bin,pkg|
  execute "npm install " + pkg do
    command "sudo /usr/bin/npm install -g --no-progress " + pkg
    not_if "which " + bin
  end
end

#############
###  END  ###
#############

# Very LAST, restart our server.
service 'nginx' do
  action :restart
end

service 'php7.1-fpm' do
  action :restart
end

