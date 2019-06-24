#!/bin/bash
# shellcheck disable=SC1090

# lazy_install.sh
# ubuntu, debian bash script
# lazy install script for sonar's customer portal
# meant to be piped to bash as securely as possible

splash_logo () {
echo -e "\e[34m"
printf "   ___  ___  _ __   __ _ _ __  "
printf "  / __|/ _ \| '_ \ / _` | '__| "
printf "  \__ \ (_) | | | | (_| | |    "
printf "  |___/\___/|_| |_|\__,_|_|    "
echo -e "\e[0m"
echo -e ""
}
                        
checksum () {
	echo -e "\e[1mPerforming script integrity test...\e[0m"
	remote_location="https://raw.githubusercontent.com/alectrocute/customer_portal/master/lazy_install.sh"
	remote=$(curl -s $remote_location|sha1sum|cut -f 1 -d " ")
	echo -e "Remote file URL:\e[4m" $remote_location
	echo -e "\e[0mRemote file hash:\e[2m" $remote
	local_file=$(cat ./hash.txt|cut -f 1 -d " ")
	echo -e "This file's hash:\e[2m" $local_file
	sudo rm hash.txt
	if [ "$remote" = "$local_file" ]
	then
	        echo -e "\e[32mSecurity check passed! Continuing with installation...\e[0m"
	else
	        echo -e "\e[31mSecurity check failed. \e[0mPlease contact support."
	        exit
	fi
}

install_portal () {
	checksum
	echo -e "\e[1mInstallation will now begin.\e[0m"
	mkdir /etc/sonar_software
	cd /etc/sonar_software
	echo -e "\e[1mUpdating packages & dependencies.\e[0m"
	sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y install git unzip
	echo -e "\e[1mDownloading latest repo from GitHub.\e[0m"
	git clone https://github.com/SonarSoftwareInc/customer_portal.git
	cd customer_portal
	echo -e "\e[1mRunning installation executable...\e[0m"
	sudo ./install.sh | tee customerportal-install.log
	echo -e "\e[32mInstallation complete! Would you like to review the install logs?\e[0m"
	read -n 1 -p "Type 'y' to view, or 'n' to decline: " view_logs < /dev/tty
	if [ "$view_logs" = 'yes' ]
	then
	        cat customerportal-install.log
	else
	        exit
	fi
}

reset
splash_logo
echo -e "This script will install the latest Sonar Customer Portal onto your server."
echo -e "To begin, confirm that you'd like to start the installation process."
echo -e ""
read -n 1 -p "Type 'y' to begin, otherwise type 'n': " confirm < /dev/tty

if [[ $confirm = 'y' ]]
then
        clear
        install_portal
	exit
else
        exit
fi
