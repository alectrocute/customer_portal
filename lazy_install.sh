#!/bin/bash
# shellcheck disable=SC1090

checksum () {
	echo "Performing script integrity test..."
	remote_location="https://portal.latest.alec.pw/install.sh"
	remote=$(curl -s $remote_location|sha1sum|cut -f 1 -d " ")
	echo "Remote file URL:" $remote_location
	echo "Remote file hash:" $remote
	local_file=$(sha1sum ./install.sh|cut -f 1 -d " ")
	echo "This file's hash:" $local_file
	if [[ $remote == $local_file ]]
	then
	        echo "Security check passed! Continuing with installation..."
	else
	        echo "Security check failed. Please contact support."
		rm -r ./install.sh
		echo "Successfully deleted potentially malicious file from disk!"
	        exit
	fi
}

install_portal () {
	checksum
	echo -e "Installation will now begin."
	sudo rm -r /etc/sonar_software
	sudo mkdir /etc/sonar_software
	cd /etc/sonar_software || echo "File system error!"; exit
	echo -e "Updating packages & dependencies."
	sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y install git unzip
	echo -e "Downloading latest repo from GitHub."
	git clone https://github.com/SonarSoftwareInc/customer_portal.git
	cd customer_portal || echo "File system error!" && exit
	echo -e "Running installation executable..."
	sudo ./install.sh | tee customerportal-install.log
	echo -e "Installation complete! Would you like to review the install logs?"
	read "Type 'yes' to view, or hit enter to decline: " view_logs
	if [ $view_logs = "yes" ]
	then
	        cat customerportal-install.log
	else
	        exit
	fi
}

reset
echo -e "This script will install the latest Sonar Customer Portal onto your server."
echo -e "To begin, confirm that you'd like to start the installation process."
echo -e ""
read -p "Type 'install' to begin: " confirm

if [ $confirm = "install" ]
then
        clear
        install_portal
else
        echo -e "Installation cancelled."
        exit
fi
