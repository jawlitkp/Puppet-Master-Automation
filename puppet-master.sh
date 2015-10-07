#! /bin/bash

# Install server function
function install_server() {

	echo "Installing RHEL 7 Puppet Labs repository"
	
	# Install puppet labs repository for RHEL 7 
	sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

	# Editing puppet configurations file with alternative dns names. Checks if line already exists. 
	grep --silent --regexp='dns_alt_name*' $PUPPET_CONF || sed -i "/\[main\]/a\    dns_alt_name = $HOSTNAME" $PUPPET_CONF

	# Creating directories in production environment
	sudo mkdir --parents /etc/puppet/environments/production/{modules, manifests}
	sudo touch $ENVIRONMENT_CONF #Create environment configuration file
	> $ENVIRONMENT_CONF #Empty file if it already exists

	# Edit configuration file with module path name
	echo -n -e "Modifying the evironment configuration file\n"
	echo -n -e "modulepath = $MODULE_PATH\nenvironment_timeout = 5s" >> $ENVIRONMENT_CONF
	
	# Create a master node declaration in the puppet configuration
	echo -n -e "Creating a master node decleration in our main puppet configuration\n"
	grep --silent '\[master\]' $PUPPET_CONF || echo -e \
	"[master]\n    environmentpath = \$confdir/environments\n    basemodulepath = \$confdir/modules:/opt/puppet/share/modules" >> $PUPPET_CONF

	# Changing SELinux to Permissive mode to remove any complications
	echo -n -e "SELinux to permissive mode\n"
	sudo setenforce permissive
	sudo sed --in-place 's\=enforcing\=permissive\g' /etc/sysconfig/selinux

	# Checks if a certificate exists. If not, generate a new one
        if [ ! -f /var/lib/puppet/ssl/public_keys/$(echo $HOSTNAME | awk '{print tolower($0)}').pem ]; then
		echo "Generating a certificate now... "
                sudo puppet master --verbose --no-daemonize
        else echo -n -e "Certificate already exists, moving on\n"
	fi

	echo -n -e "Adding TCP Port 8140 to Firewall.\n"
	#Adding puppet port 8140 to the firewall
	sudo firewall-cmd --permanent --add-port=8140/tcp
	sudo firewall-cmd --reload
	}
