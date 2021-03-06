#!/bin/bash
# This script installs OpenY on DigitalOcean Drupal instance.
# How to run: bash <(curl -s https://raw.githubusercontent.com/ymcatwincities/openy/8.x-1.x/build/openy-digital-ocean.sh)

# Colors.
Color_Off='\033[0m'       # Text Reset
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

printf "${Green}Installing git...${Color_Off}\n"
sudo apt-get install git -y

printf "${Green}Installing composer...${Color_Off}\n"
wget https://getcomposer.org/composer.phar
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

printf "${Green}Installing SWAP...${Color_Off}\n"
sudo dd if=/dev/zero of=/swapspace bs=1M count=4000
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab

printf "${Green}Updading nginx virtual hosts...${Color_Off}\n"
sudo sed -i "s/html\/drupal/openy\/docroot/g" /etc/nginx/sites-enabled/drupal
sudo service nginx restart

printf "${Green}Installing OpenY...${Color_Off}\n"
composer create-project ymcatwincities/openy-project:8.1.x-dev /var/www/openy --no-interaction
cp /var/www/html/drupal/sites/default/settings.php /var/www/openy/docroot/sites/default/settings.php
mkdir /var/www/openy/docroot/sites/default/files
sudo chmod -R 777 /var/www/openy/docroot/sites/default/settings.php
sudo chmod -R 777 /var/www/openy/docroot/sites/default/files
MYSQL="$(drush sql-connect -r /var/www/openy/docroot)"
$MYSQL -e "drop database drupal; create database drupal;"
IP="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"

printf "\n${Green}Open http://$IP/core/install.php to proceed with OpenY installation.${Color_Off}\n"
