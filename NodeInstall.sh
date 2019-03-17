#!/bin/bash

###### you must be logged in as a sudo user, not root #######

COIN_NAME='zelcash'

#current wallet version found @https://github.com/zelcash/zelcash/releases
WALLET_DOWNLOAD='https://github.com/zelcash/zelcash/releases/download/v3.1.0/ZelCash-Linux.tar.gz'
FETCHPARAMS='https://raw.githubusercontent.com/zelcash/zelcash/master/zcutil/fetch-params.sh'
WALLET_BOOTSTRAP='https://zelcore.io/zelcashbootstraptxindex.zip'
BOOTSTRAP_ZIP_FILE='zelcashbootstraptxindex.zip'
WALLET_TAR_FILE='ZelCash-Linux.tar.gz'
ZIPTAR='unzip'
CONFIG_FILE='zelcash.conf'
RPCPORT=16124
PORT=16125
COIN_DAEMON='zelcashd'
COIN_CLI='zelcash-cli'
COIN_TX='zelcash-tx'
COIN_PATH='/usr/bin'
USERNAME=$(who -m | awk '{print $1;}')
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'
STOP='\e[0m'
 
#countdown "00:00:30" is a 30 second countdown that provides output for forced pauses
countdown()
(
  IFS=:
  set -- $*
  secs=$(( ${1#0} * 3600 + ${2#0} * 60 + ${3#0} ))
  while [ $secs -gt 0 ]
  do
    sleep 1 &
    printf "\r%02d:%02d:%02d" $((secs/3600)) $(( (secs/60)%60)) $((secs%60))
    secs=$(( $secs - 1 ))
    wait
  done
  echo -e "\033[1K"
)

#Suppressing password promts for this user so node can operate
sudo echo -e "$(who -m | awk '{print $1;}') ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo
clear
echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'Node Setup for ZEL'
echo -e 'March 11, 2019'
echo -e '\033[1;33m===============================================================================\033[0m'

echo -e
echo -e '\033[1;36mNode setup starting, press [CTRL-C] to cancel.\033[0m'
countdown "00:00:05"
echo -e

if [ "$USERNAME" = "root" ]; then
    echo -e "\033[1;36mYou are currently logged in as \033[0mroot\033[1;36m, please log out and\nlog back in with the username you just created.\033[0m"
    exit
fi
    #echo -e "Hello $USERNAME, please enter your password: "
    #[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'INSTALLING NODE DEPENDENCIES'
echo -e '\033[1;33m===============================================================================\033[0m'
echo "Installing packages and updates..."
sleep 3
sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install nano htop pwgen ufw figlet -y
sudo apt-get install build-essential libtool pkg-config -y
sudo apt-get install libc6-dev m4 g++-multilib -y
sudo apt-get install autoconf ncurses-dev unzip git python python-zmq -y
sudo apt-get install wget curl bsdmainutils automake -y
echo -e

echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'CREATE CONF FILE'
echo -e '\033[1;33m===============================================================================\033[0m'
if [ -f ~/.zelcash/zelcash.conf ]; then
    echo -e "\033[1;36mExisting conf file found, backing up to zelcash.old ...\033[0m"
    sudo mv ~/.zelcash/zelcash.conf ~/.zelcash/zelcash.old;
fi

RPCUSER=`pwgen -1 8 -n`
PASSWORD=`pwgen -1 20 -n`
if [ "x$PASSWORD" = "x" ]; then
    PASSWORD=${WANIP}-`date +%s`
fi
    echo -e "\n\033[1;32mCreating MainNet Conf File...\033[0m"
    sleep 3
    mkdir ~/.zelcash
    touch ~/.zelcash/$CONFIG_FILE
    echo "rpcuser=$RPCUSER" >> ~/.zelcash/$CONFIG_FILE
    echo "rpcpassword=$PASSWORD" >> ~/.zelcash/$CONFIG_FILE
    echo "rpcallowip=127.0.0.1" >> ~/.zelcash/$CONFIG_FILE
    #echo "rpcport=$RPCPORT" >> ~/.zelcash/$CONFIG_FILE
    #echo "port=$PORT" >> ~/.zelcash/$CONFIG_FILE
    echo "daemon=1" >> ~/.zelcash/$CONFIG_FILE
    echo "txindex=1" >> ~/.zelcash/$CONFIG_FILE
    echo "addnode=explorer.zel.cash" >> ~/.zelcash/$CONFIG_FILE
    echo "addnode=explorer.zel.zelcore.io" >> ~/.zelcash/$CONFIG_FILE
    echo "addnode=explorer2.zel.cash" >> ~/.zelcash/$CONFIG_FILE
    echo "addnode=explorer.zelcash.online" >> ~/.zelcash/$CONFIG_FILE
    echo "addnode=node-eu.zelcash.com" >> ~/.zelcash/$CONFIG_FILE
    echo "addnode=node-uk.zelcash.com" >> ~/.zelcash/$CONFIG_FILE
    echo "addnode=node-asia.zelcash.com" >> ~/.zelcash/$CONFIG_FILE
    echo "maxconnections=256" >> ~/.zelcash/$CONFIG_FILE

sleep 3

echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'DOWNLOAD AND INSTALL WALETT BINARIES'
echo -e '\033[1;33m===============================================================================\033[0m'
echo -e "\033[1;32mKilling and removing any old instances of $COIN_NAME."
echo -e "Downloading new wallet...\033[0m"
sudo killall $COIN_DAEMON > /dev/null 2>&1
cd /usr/bin && sudo rm $COIN_CLI $COIN_DAEMON > /dev/null 2>&1 && sleep 2
# added to be sure to delete the old files for someone using the old script
cd /usr/local/bin && sudo rm $COIN_CLI $COIN_DAEMON > /dev/null 2>&1 && sleep 2
cd
wget -c $WALLET_DOWNLOAD -O - | sudo tar -xz &> /dev/null
sudo mv $COIN_DAEMON $COIN_CLI $COIN_TX /usr/bin
sudo chmod 555 /usr/bin/zelcash*
sudo rm -rf $WALLET_TAR_FILE && sudo rm -rf ~/zelcash-gtest && sudo rm -rf ~/fetch-params.sh
echo -e

echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'DOWNLOAD WALLET BOOTSTRAP'
echo -e '\033[1;33m===============================================================================\033[0m'
wget -U Mozilla/5.0 $WALLET_BOOTSTRAP
unzip -o $BOOTSTRAP_ZIP_FILE -d /home/$USERNAME/.zelcash
rm -rf $BOOTSTRAP_ZIP_FILE
echo -e

echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'DOWNLOAD CHAIN PARAMS'
echo -e '\033[1;33m===============================================================================\033[0m'
wget -q $FETCHPARAMS
chmod 770 fetch-params.sh &> /dev/null
sudo bash fetch-params.sh
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
rm fetch-params.sh
echo -e

echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'ADD DAEMON AS SYSTEMD SERVICE'
echo -e '\033[1;33m===============================================================================\033[0m'
sudo touch /etc/systemd/system/$COIN_NAME.service
sudo chown $USERNAME:$USERNAME /etc/systemd/system/$COIN_NAME.service
cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
Type=forking
User=$USERNAME
Group=$USERNAME
WorkingDirectory=/home/$USERNAME/.zelcash/
ExecStart=$COIN_PATH/$COIN_DAEMON -datadir=/home/$USERNAME/.zelcash/ -conf=/home/$USERNAME/.zelcash/$CONFIG_FILE -daemon
ExecStop=-$COIN_PATH/$COIN_CLI stop
Restart=always
RestartSec=3
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF
sudo chown root:root /etc/systemd/system/$COIN_NAME.service
sudo systemctl daemon-reload
sleep 3
sudo systemctl enable $COIN_NAME.service &> /dev/null
echo -e

echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'CONFIGURE FIREWALL AND ENABLE FAIL2BAN'
echo -e '\033[1;33m===============================================================================\033[0m'
sudo ufw allow ssh/tcp
sudo ufw allow $PORT/tcp
sudo ufw logging on
sudo ufw default deny incoming
sudo ufw default allow outgoing
echo "y" | sudo ufw enable >/dev/null 2>&1
sudo systemctl enable fail2ban >/dev/null 2>&1
sudo systemctl start fail2ban >/dev/null 2>&1
echo -e

echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'SYNCING BLOCKCHAIN, PLEASE BE PATIENT'
echo -e '\033[1;33m===============================================================================\033[0m'
echo -e
$COIN_DAEMON -daemon &> /dev/null
countdown "00:05:00"
$COIN_CLI stop &> /dev/null
sleep 15
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
echo -e "\033[1;32mRestarting ZelNode Daemon...\033[0m"
$COIN_DAEMON -daemon &> /dev/null
for (( counter=30; counter>0; counter-- ))
do
echo -n ". "
sleep 1
done
printf "\n"

sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
echo -e "\033[1;32mFinalizing Node Setup...\033[0m"
sleep 5

printf "\033[1;34m"
figlet -t -k "WELCOME   TO   ZELNODES" 
printf "\e[0m"

echo -e
read -n1 -r -p "Press any key to continue..." key
for (( countera=120; countera>0; countera-- ))
do
clear

echo -e '\033[1;33m===============================================================================\033[0m'
echo -e 'NODE SYNC STATUS - REFRESHES EVERY 10 SECONDS'
echo -e '\033[1;33m===============================================================================\033[0m'
echo -e
$COIN_CLI getinfo
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
echo -e '\033[1;32mPress [CTRL-C] when correct blockheight has been reached to exit.\033[0m'
    countdown "00:00:10"
done
printf "\n"
