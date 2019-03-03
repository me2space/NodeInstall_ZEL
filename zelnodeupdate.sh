#!/bin/bash

###### you must be logged in as a sudo user, not root #######
# This script will update your ZelNode daemon to the current release

#wallet information
COIN_NAME='hush'
WALLET_DOWNLOAD='https://github.com/Myhush/hush/releases/download/v2.0.0/hush-2.0.0.tar.gz'
WALLET_BOOTSTRAP='https://zelcore.io/zelcashbootstraptxindex.zip'
BOOTSTRAP_ZIP_FILE='zelcashbootstraptxindex.zip'
WALLET_TAR_FILE='hush-2.0.0.tar.gz'
ZIPTAR='unzip'
CONFIG_FILE='hush.conf'
RPCPORT=8822
PORT=8888
COIN_DAEMON='hushd'
COIN_CLI='hush-cli'
COIN_PATH='/usr/bin'
USERNAME=$(who -m | awk '{print $1;}')
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'
STOP='\e[0m'
FETCHPARAMS='https://raw.githubusercontent.com/Myhush/hush/master/zcutil/fetch-params.sh'
#end of required details

#Display script name and version
clear
echo -e '\033[1;33m==================================================================\033[0m'
echo -e 'Hush Node, v2.0.0'
echo -e '\033[1;33m==================================================================\033[0m'
echo -e '\033[1;34m19 Mar. 2019, by alltank fam, dk808zelnode, Goose-Tech & Skyslayer\033[0m'
echo -e
echo -e '\033[1;36mZelNode update starting, press [CTRL-C] to cancel.\033[0m'
sleep 3
echo -e
#check for correct user
USERNAME=$(who -m | awk '{print $1;}')
echo -e "\033[1;36mYou are currently logged in as \033[0m$USERNAME\033[1;36m.\n\n"
read -p 'Was this the username used to install the ZelNode? [Y/n] ' -n 1 -r
if [[ $REPLY =~ ^[Nn]$ ]]
then
    echo ""
    echo -e "\033[1;33mPlease log out and login with the username you created for your ZelNode.\033[0m"
      exit 1
fi
#check for root and exit with notice if user is root
ISROOT=$(whoami | awk '{print $1;}')
if [ "$ISROOT" = "root" ]; then
    echo -e "\033[1;36mYou are currently logged in as \033[0mroot\033[1;36m, please log out and\nlog back in with as your sudo user.\033[0m"
    exit
fi

#Install Ubuntu updates
echo -e "\033[1;33m=======================================================\033[0m"
echo "Updating your OS..."
echo -e "\033[1;33m=======================================================\033[0m"
echo "Installing package updates..."
sudo apt-get update -y
sudo apt-get upgrade -y
echo -e "\033[1;32mLinux Packages Updates complete...\033[0m"
sleep 2
#Setup log rotation
echo -e "\n\033[1;33mConfiguring log rotate function...\033[0m"
sleep 1
if [ -f /etc/logrotate.d/hushdebuglog ]; then
    echo -e "\033[1;36mExisting log rotate conf found, backing up to ~/hushdebuglogrotate.old ...\033[0m"
    sudo mv /etc/logrotate.d/hushdebuglog ~/hushdebuglogrotate.old;
    sleep 2
fi
touch /home/$USERNAME/hushdebuglog
cat <<EOM > /home/$USERNAME/hushdebuglog
/home/$USERNAME/.hush/debug.log {
    compress
    copytruncate
    missingok
    daily
    rotate 7
}
EOM
cat /home/$USERNAME/hushdebuglog | sudo tee -a /etc/logrotate.d/hushdebuglog > /dev/null
rm /home/$USERNAME/hushdebuglog
sudo logrotate --force /etc/logrotate.d/hushdebuglog
echo -e "\n\033[1;32mLog rotate configuration complete.\n~/.hush/debug.log file will be backed up daily for 7 days then rotated.\033[0m"
sleep 5

#Closing zelcash daemon
echo -e "\033[1;33mStopping & removing all old instances of $COIN_NAME and Downloading new wallet...\033[0m"
sudo systemctl stop hush > /dev/null 2>&1 && sleep 3
sudo hush-cli stop > /dev/null 2>&1 && sleep 5
sudo killall $COIN_DAEMON > /dev/null 2>&1
#Removing old zelcash files
sudo rm -rf /usr/bin/zelcash* > /dev/null 2>&1
echo -e "\033[1;33mDownloading new wallet binaries...\033[0m"
#begin downloading wallet binaries
cd
mkdir ~/zeltemp
wget -c $WALLET_DOWNLOAD -O - | tar -xz -C ~/hushtemp
#copy daemon files to bin directory and change perms to X
sudo cp ~/hushtemp/hush* /usr/bin
sudo chmod 755 /usr/bin/hush*
#remove temp files
rm -rf $WALLET_TAR_FILE && rm -rf ~/hushtemp
cd
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
#Notice to user we are complete and request a reboot
echo -e "\033[1;32mUpdate complete.\nPlease reboot the VPS by typing: \033[0msudo reboot -n\033[1;32m."
echo -e "Then verify the Hush daemon has started by typing: \033[0mhush-cli getinfo\033[1;32m.\033[0m"
