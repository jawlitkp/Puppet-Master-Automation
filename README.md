# Puppet-Master-Automation
Automates the process of installing and configuring a working Puppet Master server. Intended for use with RHEL 7/CentOS systems.

- Configures the directory structure for the puppet master
- Modifies main puppet configuration with master declaration and alternative DNS names
- Adds TCP/8140 entries to firewall which is the listening port for the puppet master web application
- Runs the passenger and Nginx module installation which runs the puppet master web applications
- Creates symbolic links to the alternate Nginx installation directory
- Generates SSL certificate for the puppetmaster and configures the configuration files in Nginx with these values
