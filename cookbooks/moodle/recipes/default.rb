#
# Cookbook Name:: moodle
# Recipe:: default
#
# Copyright 2014, Moodlerooms, Inc.
#
# All rights reserved - Do Not Redistribute
#

########################
###  INSTALL APACHE  ###
########################

%w{apache2 libapache2-mod-php libapache2-mod-xsendfile}.each do |pkg|
  package pkg do
    action :install
  end
end

# Configuration file for xsendfile.
template "/etc/apache2/conf-available/moodle-xsendfile.conf" do
  source "xsendfile.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
    :user => node['moodle']['user']
  })
end

# Enable xsendfile configuration.
execute "a2enconf moodle-xsendfile" do
  command "sudo /usr/sbin/a2enconf moodle-xsendfile"
end

# Configuration file for extra ports.
cookbook_file "/etc/apache2/conf-available/moodle-port.conf" do
  source "port.conf"
  owner "root"
  group "root"
  mode 0644
end

# Enable port configuration.
execute "a2enconf moodle-port" do
  command "sudo /usr/sbin/a2enconf moodle-port"
end

# Enable Apache SSL.
execute "a2enmod ssl" do
  command "sudo /usr/sbin/a2enmod ssl"
end

# Run Apache as our user and group.
ruby_block "Change Apache user and group" do
  block do
    file = Chef::Util::FileEdit.new("/etc/apache2/envvars")
    file.search_file_replace_line(/export APACHE_RUN_USER=www-data/,"export APACHE_RUN_USER="+node['moodle']['user'])
    file.search_file_replace_line(/export APACHE_RUN_GROUP=www-data/,"export APACHE_RUN_GROUP="+node['moodle']['group'])
    file.write_file
  end
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

##########################
###  INSTALL PACKAGES  ###
##########################

node['moodle']['packages'].each do |pkg|
  package pkg do
    action :install
  end
end

#######################
###  CONFIGURE PHP  ###
#######################

# Add custom PHP ini settings.
template "/etc/php/7.0/mods-available/moodle.ini" do
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
  owner "root"
  group "root"
  mode 0666
end

#####################
###  MOODLE SITE  ###
#####################

# Create default site for Moodle.  Allow for customization by not overriding.
template "/etc/apache2/sites-available/moodle.conf" do
  source "vhost.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
    :server_name => 'moodle.dev',
    :server_alias => '*.vagrantshare.com',
    :docroot => '/vagrant/www/moodle',
    :name => 'moodle',
  })
end

# Enable the moodle site.
execute "a2ensite moodle.conf" do
  command "sudo /usr/sbin/a2ensite moodle.conf"
end

# Ensure moodledata directory exists in the home directory.
directory '/home/' + node['moodle']['user'] + '/moodledata' do
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0777
end

##########################
###  CORE MOODLE SITE  ###
##########################

# Create site for core moodle.
template "/etc/apache2/sites-available/core-moodle.conf" do
  source "vhost.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
    :server_name => 'core-moodle.dev',
    :docroot => '/vagrant/www/core-moodle',
    :name => 'core-moodle'
  })
end

# Enable the core-moodle site.
execute "a2ensite core-moodle.conf" do
  command "sudo /usr/sbin/a2ensite core-moodle.conf"
end

##################
###  WEBGRIND  ###
##################

# Create base directory for webgrind.
directory '/home/' + node['moodle']['user'] + '/www' do
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0644
end

# Grab the webgrind code.
git '/home/' + node['moodle']['user'] + '/www/webgrind' do
  repository "https://github.com/jokkedk/webgrind.git"
  revision "v1.4.0"
end

# Compile the preprocessor to improve performance.
execute "make webgrind" do
  command "make clean && make"
  cwd '/home/' + node['moodle']['user'] + '/www/webgrind'
end

# Create site for webgrind.
template "/etc/apache2/sites-available/webgrind.conf" do
  source "vhost.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
    :server_name => 'webgrind.dev',
    :docroot => '/home/' + node['moodle']['user'] + '/www/webgrind',
    :name => 'webgrind'
  })
end

# Enable the webgrind site.
execute "a2ensite webgrind.conf" do
  command "sudo /usr/sbin/a2ensite webgrind.conf"
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
    command "sudo /usr/bin/npm install -g --progress=false " + pkg
    not_if "which " + bin
  end
end

#############
###  END  ###
#############

# Very LAST, restart Apache.
service 'apache2' do
  action :restart
end
