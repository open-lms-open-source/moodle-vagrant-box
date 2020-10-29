#
# Cookbook Name:: moodle
# Attributes file
#
# Copyright 2017 Open LMS. (https://www.openlms.net)

# The account details of the default user (EG: who you SSH in as).
default['moodle']['user']  = 'vagrant'
default['moodle']['group'] = 'vagrant'

# Other packages to install.
default['moodle']['packages'] = [
  'git',                      # Because we git.
  'bash-completion',          # Was removed from base box.
  'curl',                     # Used for downloads.
  'clamav',                   # For Anti-virus in Moodle file uploads.
  'ghostscript',              # Ghostscript: for PDF annotation in Moodle.
  'unoconv',                  # For grading assignments in Moodle.
  'graphviz',                 # Graphing tool used by webgrind.
  'nodejs',                   # For grunt-cli, etc.
  'default-jre-headless',     # For Behat.
  'xvfb',                     # For Behat.
  'firefox',                  # For Behat.
  'chromium-browser',         # For Behat.
  'chromium-chromedriver',    # For Behat, installs /usr/lib/chromium-browser/chromedriver
  'google-chrome-stable',     # For Behat.
  'nginx',                    # Our web server.
  'nmon',                     # Performance monitoring tool.
  'php7.4-phpdbg',            # PHP debugging and code coverage tool.
  'mysql-server',             # MySQL.
  'redis-server',             # Redis.
  'libmcrypt-dev',            # For installing mcrypt.
  'php-dev',                  # For installing mcrypt.
  'php-pear',                 # For installing mcrypt.
]

# PHP specific packages to install.
default['moodle']['php']['packages'] = [
  'php-apcu',
  'php7.4-bcmath',
  'php7.4-curl',
  'php7.4-gd',
  'php-imagick',
  'php7.4-imap',
  'php7.4-intl',
  'php7.4-ldap',
  'php7.4-mbstring',
  'php7.4-mysql',
  'php7.4-pgsql',
  'php7.4-pspell',
  'php-redis',
  'php7.4-soap',
  'php-ssh2',
  'php-xdebug',
  'php7.4-xml',
  'php7.4-xmlrpc',
  'php7.4-zip'
]

# PHP ini configs that can be overridden.
default['moodle']['php']['ini'] = {
  :date_timezone => 'America/Los_Angeles',
}

# NPM packages to install.
default['moodle']['npm']['packages'] = {
  :grunt   => 'grunt-cli',
  :vnujar  => 'vnu-jar@">=17.3.0 <18.0.0"',
}
