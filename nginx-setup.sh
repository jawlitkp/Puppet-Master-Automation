#! /bin/bash

# Setups up Nginx and passenger for puppet master
function install_nginx() {

	#Install nginx and pacakges needed to set up Ruby
	sudo yum install -y mod_ssl ruby-devel rubygems gcc gcc-c++ libcurl-devel openssl-devel

	# Installs rack and passenger mdoules for the webserver
	sudo gem install rack passenger

	# Runs the nginx installer module. Will download and configure nginx with passenger. May need to be ran as root	
	passenger-install nginx

	# Creating symbolic links to default nginx locations
	ln -s /opt/nginx/conf /etc/nginx
	ln -s /opt/nginx/logs /var/log/nginx
	ln -s /opt/nginx/sbin/nginx /usr/sbin/nginx

	# sudo curl -L https://raw.github.com/z0mbix/puppet-master-nginx-passenger/master/etc/rc.d/init.d/nginx -o /etc/init.d/nginx
	# chmod +x /etc/init.d/nginx

	sudo mkdir -p /etc/nginx/conf.d
	sudo cp puppet.conf /etc/nginx/conf.d/

	# Setting up directories
	sudo mkdir -p /etc/puppet/rack/{public,tmp}
	sudo cp /usr/share/puppet/ext/rack/config.ru /etc/puppet/rack/
	sudo chown -R puppet:puppet /etc/puppet/rack

	sudo systemctl enable nginx
	sudo systemctl start nginx

}

install_nginx
