# Installeren van php 
sudo apt-get install php7.0

# Add de repository van PHP7.0
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt search php7

# Installeren van php extensies
sudo apt-get install -y php7.0-curl
sudo apt-get install -y php7.0-common
sudo apt-get install -y php7.0-gd
sudo apt-get install -y php7.0-mysql
sudo apt-get install -y libapache2-mod-php7.0
sudo apt-get install -y php7.0-mbstring
sudo apt-get install -y php7.0-mcrypt
sudo apt-get install -y php7.0-xml
sudo apt-get install -y php7.0-zip

# Heropstarten webserver
sudo service apache2 restart

# enable mod_rewrite
sudo a2enmod rewrite

# Integratie met drupal
cd ~
wget https://ftp.drupal.org/files/projects/drupal-8.8.4.tar.gz
tar xzvf drupal-8.8.4.tar.gz
cd drupal-8.8.4
sudo rsync -avz . /var/www/html
mkdir /var/www/html/sites/default/files
cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php
chmod 664 /var/www/html/sites/default/settings.php
sudo chown -R :www-data /var/www/html/*
