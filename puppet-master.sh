#! /bin/bash

# Exit on simple error
set -e

# Standard error function
function error(){
	echo -e "[Error] $1"
	exit 1;
}

# Exit if the user is no root
if [ $(id -u) != 0 ]; then
	error "You are not logged in as root".
	exit 1;
fi

function print_msg(){
	echo -e -n "$1\n"

}
			
			
# Setting up variables
PUPPET_CONF=/etc/puppet/puppet.conf
ENVIRONMENT_CONF=/etc/puppet/environments/production/environment.conf
MODULE_PATH=/etc/puppet/environments/production/modules
MASTERHOST="some value"


# Install server function
function install_puppet() {


	# Exit installation if puppet installation is found
	if [ -d '/var/lib/puppet' ]; then 
		error "Puppet is already installed"
	else
		echo "Starting the installation."

	fi
	# Install puppet labs repository for RHEL 7 
	rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm && : || error "Failed to add the puppet labs repository"

}

# Configures the puppet master
function puppet_master(){

	yum install puppet-server -y || error "Failed to install the puppet master server"

	#Adding puppet port 8140 to the firewall
	firewall-cmd --permanent --add-port=8140/tcp || error "Failed to add entry to the firewall"
	firewall-cmd --reload || error "Firewall could not be restarted"
	
	print_msg "Adding TCP Port 8140 to Firewall."
	# Editing puppet configurations file with alternative dns names. Checks if line already exists. 
	grep --silent --regexp='dns_alt_name*' $PUPPET_CONF || \ 
	sed -i "/\[main\]/a\    dns_alt_name = $HOSTNAME" $PUPPET_CONF || error "Failed to modify the configuration"

	# Creating directories in production environment
 	mkdir --parents /etc/puppet/environments/production/{modules,manifests} || error "Failed to make the puppet environment directories"

	if [ -f $ENVIRONMENT_CONF ]; then
		print_msg "Puppet configuration already exists."
	else
		touch $ENVIRONMENT_CONF || error "Could not create environment configuration file"
	fi

	# Edit configuration file with module path name
	echo -n -e "modulepath = $MODULE_PATH\nenvironment_timeout = 5s" >> $ENVIRONMENT_CONF
	
	# Create a master node declaration in the puppet configuration
	print_msg "Creating a master node decleration in our main puppet configuration"
	grep --silent '\[master\]' $PUPPET_CONF || echo -e \
	"[master]\n    environmentpath = \$confdir/environments\n    basemodulepath = \$confdir/modules:/opt/puppet/share/modules" >> $PUPPET_CONF
	# Changing SELinux to Permissive mode to remove any complications
	print_msg "SELinux to permissive mode"
	setenforce permissive || error "Failed to change SELinux to permissive"

	sed --in-place 's\=enforcing\=permissive\g' /etc/sysconfig/selinux || error "Unable to edit the SELinux configuration file"

	# Checks if a certificate exists. If not, generate a new one
        if [ ! -f /var/lib/puppet/ssl/public_keys/$(echo $HOSTNAME | awk '{print tolower($0)}').pem ]; then
		print_msg "Generating a certificate now... "
                puppet master --verbose --no-daemonize || error "Failed to generate an SSL certificate for the master"
        else 
		echo -n -e "Certificate already exists, moving on\n"
	fi

}
# Configured puppet on the agent node
function install_agent(){
	print_msg "Installing puppet agent"
	yum install -y puppet || error "Failed to install puppet agent software"
	
	# Edit puppet agent configuration with master host details
	print_msg "Modifying puppet configuration and start up options"
	sed -i "2i server=to edit later" $PUPPET_CONF || error "Failed to modify puppet agent configuration"
	systemctl enable puppet || error "Failed to allow the puppet agent to run at start up"
	systemctl restart puppet || error "Failed to restart puppet agent"

}

# while getopts ":hdm: --help" opt; do 
while getopts h:d:m opt; do
	case $opt in
		h|--help) echo "Some help informationi and $opt";;
		d) echo "domain option";;
		m) echo "m option";;
	esac
done

# puppet_master

exit 0
