#!/bin/bash

sudo apt update
sudo apt upgrade -y
sudo apt clean -y
sudo apt autoclean -y
sudo apt autoremove -y
sudo touch /.ssh

ctrl_interface="DIR=/var/run/wpa_supplicant GROUP=netdev"
update_config=1
country=KEN

network={
    ssid="flying-spaghetti-monster"
    psk="Gsxr-1300."
    scan_ssid=1
}
