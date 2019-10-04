#!/bin/bash
# Lucent Core Installation Script for Debian - LCNT v0.12.3.3 (October 2, 2019 Revision #2)
# Approved by John Razmus
# Written by AlphaSerpentis#3203 (Lucent Core Tech Lead)
# Lucent Core (for Debian) Installation Script is based upon C1ph3r117#6078 and Daywalker#3486 Lucent Masternode Script (https://github.com/LucentCoin/Lucent/releases)
# NOTICE: This script is EXPERIMENTAL!

#Introductory

clear
cd
echo "Thank you for installing Lucent Core! Your installation will begin shortly"
sleep 5

# Dependencies Download & Installation

echo "Downloading dependencies..."

sudo apt-get install software-properties-common

echo "Updating packages..."
sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade

echo "Installing the unzip package..."

sudo apt install unzip

echo "Installing build requirements..."
sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils wget libdb4.8 libdb++-dev libboost-all-dev curl

# Lucent Core Download & Installation (Part 1 - Before make)
echo "Downloading Lucent Core..."
wget https://github.com/LucentCoin/Lucent/archive/v0.12.3.3.zip && unzip -o v0.12.3.3.zip
rm v0.12.3.3.zip
cd Lucent-0.12.3.3

echo "Autogenerating..."
./autogen.sh

OPTGUI=$1 # Y/N for GUI (QT)
read -e -p "Would you like to install the GUI (QT) with Lucent Core? [Y/N]: " OPTGUI

if [[ ${OPTGUI^} == "Y" ]]; then
  echo "Downloading GUI dependencies..."
  sudo apt-get install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
  echo "Configuring with GUI!"
  ./configure --with-incompatible-bdb
elif [[ ${OPTGUI^} == "N" ]]; then
  echo "Configuring WITHOUT GUI!"
  ./configure --without-gui --with-incompatible-bdb
else
  echo "DEFAULTING TO NO GUI!"
  ./configure --without-gui --with-incompatible-bdb
fi

echo "NOTICE: The make process MIGHT take a while! Do NOT close the terminal while it is making!"
sleep 3
sudo make

echo "Completed make! Now installing..."
sleep 3
sudo make install

echo "Preparing to configure Lucent Core..."
sleep 3
cd && cd .lucentcore/
wget https://github.com/LucentCoin/Lucent/releases/download/v0.12.3.3/lucent_conf_updated_5_6_19.zip && unzip -o lucent_conf_updated_5_6_19.zip
rm lucent_conf_updated_5_6_19.zip

echo "Launching Lucent Core... Waiting for it to initialize..."
lucentd --daemon
sleep 5 # Allow time for Lucent Core to obtain info on the blockchain network

clear
# Lucent Core Masternode (optional)
OPTMN=$1 # Y/N
read -e -p "Are you running a Masternode with this wallet? [Y/N]: " OPTMN

if [[ ${OPTMN^} == "Y" ]]; then
  IP="192.168.1.1" # This is the default, please do not actually use this.
  PORT="9916"
  MASTERNODEKEY=""

  echo "Preparing Masternode... You will need to have at least 16000 Lucent on hand!"
  sleep 3
  echo "Generating masternode key..."
  MASTERNODEKEY=`lucent-cli masternode genkey`

  read -e -p "What IPv4 address would you like to use? (DO NOT INCLUDE THE PORT) : " IP

  if [[ $IP == "192.168.1.1" ]]; then
    echo "No IPv4 address was provided, scanning..."
    IP=$(curl http://icanhazip.com --ipv4)
  fi

  echo "Your Masternode Address is "$IP:$PORT
  echo "externalip="$IP:$PORT >> lucent.conf && echo "addnode="$IP >> lucent.conf && echo "masternode=1" >> lucent.conf && echo "masternodeprivkey="$MASTERNODEKEY >> lucent.conf

  sleep 1
  echo "Restarting Lucent Core..."
  lucent-cli stop
  sleep 6 # Give it time to shutdown properly...
  lucentd --daemon
  sleep 6 # Give it time to load...

fi

# End
echo "Lucent Core Installation complete! Run \`lucent-cli\` help to view the commands and \`lucent-cli\` stop to stop Lucent Core as you wish. Run \`lucentd --daemon\` to start Lucent Core if it is no longer running. If you need further assistance, feel free to contact the Lucent Core Developers, or the author of this script (AlphaSerpentis#3203)"
