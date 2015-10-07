# Puppet-Master-Automation
Automates the process of installing and configuring a working Puppet Master server

- Installs puppet master server
- Changes puppet and environment configuration files
- Adds TCP/8140 entries to firewall
- Installs and configures Nginx with passenger to run the puppet master application, listening on port 8140
- Generates SSL certificate for the puppetmaster and configures the configuration files in Nginx with these values
