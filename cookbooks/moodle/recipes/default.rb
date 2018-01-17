#
# Cookbook Name:: moodle
# Recipe:: default
#
# Copyright 2017 Blackboard Inc. (http://www.blackboard.com)

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
  common_name 'moodle.test'
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

# Copy our SQL file to tmp.
cookbook_file "/tmp/install.sql" do
  source "install.sql"
  owner "root"
  group "root"
  mode 0644
end

# Run our SQL file, it fixes root user and secures the MySQL install.
execute "MySQL setup" do
  command "sudo mysql < /tmp/install.sql"
  not_if 'test -f /etc/mysql/conf.d/moodle.cnf'
end

# Cleanup.
file "/tmp/install.sql" do
  action :delete
end

# Add extra MySQL configs to run Moodle.
cookbook_file "/etc/mysql/conf.d/moodle.cnf" do
  source "mysql.cnf"
  owner "root"
  group "root"
  mode 0644
end

# Bind MySQL to 0.0.0.0 to allow outside connections.
ruby_block "MySQL Bind Address" do
  block do
    file = Chef::Util::FileEdit.new("/etc/mysql/mysql.conf.d/mysqld.cnf")
    file.search_file_replace_line(/bind-address\W+=\W+127\.0\.0\.1/,"bind-address = 0.0.0.0")
    file.write_file
  end
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
  extensionName = pkg.gsub(/php[\d\.]*-/, "")
  if extensionName == "mysql"
    extensionName = "mysqli" # The mysql package provides mysqli.
  end
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

# Create a directory for profiles.
directory '/srv/xdebug-profiles' do
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0777
end

#####################
###  MOODLE SITE  ###
#####################

# Create default site for Moodle.
template "/etc/nginx/sites-enabled/moodle" do
  source "server.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
    :server_name => 'moodle.test *.vagrantshare.com',
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
    :server_name => 'core-moodle.test',
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
    :server_name => 'webgrind.test',
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
# WARNING: If Selenium file name is updated, also update files/default/sv-selenium-run.erb
remote_file '/usr/local/bin/selenium-server-standalone-2.53.1.jar' do
  source 'http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar'
  checksum '1cce6d3a5ca5b2e32be18ca5107d4f21bddaa9a18700e3b117768f13040b7cf8'
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0755
end

# Install a newer version of Chrome Driver due to Chrome being version >= 62.
remote_file '/usr/local/bin/chromedriver.zip' do
  source 'https://chromedriver.storage.googleapis.com/2.33/chromedriver_linux64.zip'
  checksum '87d0059ab1579ec9c10ef34ab9817feea59e19a96c029d78349a57c36db5bb74'
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0755
  not_if { ::File.exist?('/usr/local/bin/chromedriver') }
end

# Unzip Chrome Driver (deletes the zip).
execute "Unzip Chrome Driver" do
  cwd '/usr/local/bin'
  command 'unzip chromedriver.zip && rm chromedriver.zip'
  creates '/usr/local/bin/chromedriver'
end

# Ensure correct permissions and owner of Chrome Driver.
file '/usr/local/bin/chromedriver' do
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0755
end

# Create a service to automatically run Xvfb.
runit_service 'xvfb' do
  default_logger true
end

# Create a service to automatically run Selenium.
runit_service 'selenium' do
  default_logger true
end

# Create a service to automatically run Chrome headless.
runit_service 'chrome' do
  default_logger true
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

##########################
###  Moodle Plugin CI  ###
##########################

# Create $HOME/.local/bin directory.
directory '/home/vagrant/.local' do
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0775
end

directory '/home/vagrant/.local/bin' do
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0775
end

# Install moodle-plugin-ci.phar.
# The command does the following:
#   1. Downloads the latest release page HTML.
#   2. Greps the HTML for the download URL fragment.
#   3. Downloads the found URL.
execute "Download latest moodle-plugin-ci.phar" do
  command "curl -LsS https://github.com/moodlerooms/moodle-plugin-ci/releases/latest | egrep -o '/moodlerooms/moodle-plugin-ci/releases/download/[0-9\.]*/moodle-plugin-ci.phar' | wget --base=https://github.com -i - -O /home/vagrant/.local/bin/moodle-plugin-ci.phar"
  creates '/home/vagrant/.local/bin/moodle-plugin-ci.phar'
end

# Make it executable.
file '/home/vagrant/.local/bin/moodle-plugin-ci.phar' do
  owner node['moodle']['user']
  group node['moodle']['group']
  mode 0775
end

#################
###  MailHog  ###
#################

# Find download URL: https://github.com/mailhog/MailHog/releases
# To make checksum, use: shasum -a 256 ~/Downloads/MailHog_linux_amd64.dms
remote_file '/usr/local/bin/MailHog' do
  source 'https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64'
  checksum 'ba921e04438e176c474d533447ae64707ffcdd1230f0153f86cb188d348f25c0'
  mode 0755
  action :create
end

# Create a service to automatically run MailHog.
runit_service 'mailhog' do
  default_logger true
end

###############
###  Redis  ###
###############

# Update Redis config so it acts like a cache store.
ruby_block "Update Redis Config" do
  block do
    file = Chef::Util::FileEdit.new("/etc/redis/redis.conf")
    file.insert_line_if_no_match("/maxmemory 256mb/", "maxmemory 256mb")
    file.insert_line_if_no_match("/maxmemory-policy allkeys-lru/", "maxmemory-policy allkeys-lru")
    file.write_file
  end
  not_if 'sudo grep -q "maxmemory 256mb" /etc/redis/redis.conf'
end

#############
###  END  ###
#############

# Clam has a background process that eats CPU.
service 'clamav-freshclam' do
  action [:stop, :disable]
end

# Restart servers at the end.
service 'mysql' do
  action :restart
end

service 'redis' do
  action :restart
end

service 'nginx' do
  action :restart
end

service 'php7.1-fpm' do
  action :restart
end

