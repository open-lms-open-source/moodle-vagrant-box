#
# Cookbook Name:: moodle
# Attributes file
#
# Copyright 2017 Blackboard Inc. (http://www.blackboard.com)

# The account details of the default user (EG: who you SSH in as).
default['moodle']['user']  = 'vagrant'
default['moodle']['group'] = 'vagrant'

# Other packages to install.
default['moodle']['packages'] = [
  'bash-completion',          # Was removed from base box.
  'curl',                     # Used for downloads.
  'clamav',                   # For Anti-virus in Moodle file uploads.
  'ghostscript',              # Ghostscript: for PDF annotation in Moodle.
  'unoconv',                  # For grading assignments in Moodle.
  'graphviz',                 # Graphing tool used by webgrind.
  'nodejs',                   # For grunt-cli, etc.
  'nodejs-legacy',            # This is needed because shifter expects node, not nodejs.
  'npm',                      # For grunt-cli, etc.
  'default-jre-headless',     # For Behat.
  'xvfb',                     # For Behat.
  'firefox',                  # For Behat.
  'chromium-browser',         # For Behat.
  'chromium-chromedriver',    # For Behat, installs /usr/lib/chromium-browser/chromedriver
  'google-chrome-stable',     # For Behat.
  'nginx',                    # Our web server.
  'nmon',                     # Performance monitoring tool.
  'php-phpdbg',               # PHP debugging and code coverage tool.
  'mysql-server',             # MySQL.
  'redis-server',             # Redis.
]

# PHP specific packages to install.
default['moodle']['php']['packages'] = [
  'php-bcmath',
  'php-curl',
  'php-gd',
  'php-imagick',
  'php-imap',
  'php-intl',
  'php-ldap',
  'php-mbstring',
  'php-mcrypt',
  'php-mysql',
  'php-pgsql',
  'php-pspell',
  'php-redis',
  'php-soap',
  'php-ssh2',
  'php-xdebug',
  'php-xmlrpc',
  'php-zip'
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