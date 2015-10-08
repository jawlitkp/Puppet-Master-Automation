#! /bin/bash

# Exit on simple error
set -e

# Standard error function
function error(){

	echo -e "[Error]\n$1"
}

# Exit if the user is no root
if [ $(id -u) != 0 ]; then
	error "You are not logged in as root". 
	exit 1;
fi


# Setting up variables
PUPPET_CONF=/etc/puppet/puppet.conf
ENVIRONMENT_CONF=/etc/puppet/environments/production/environment.conf
MODULE_PATH=/etc/puppet/environments/production/modules

source puppet-master.sh

echo -n "Do you want to set up a puppet master node? "
read ANSWER

# Call puppet server installation if yes, check for puppet agent installation if no
case $ANSWER in
	y|yes|Y|YES) install_server;; #Call the master node installer
	n|no|N|No) 
		echo -n "Then do you want to set up a puppet node? "
		read ANSWER
		case $ANSWER in
			y|yes|Y|YES) install_agent;;
			n|no|N|NO) echo -n -e "You need to make up your mind. Exiting";;
		esac
		;;
	*) echo -n "Please enter yes or no."
esac

