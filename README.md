# How to build a LAMP development environment in Vagrant
  > The LAMP development environment will consist of Linux, Apache, MySQL, and PHP. We will use drupal as PHP-application. Drupal is an open-source CMS (i.e. Content Management System) in which websites and blogs can be developed and managed.
 ### Software
 First of all download the software.
 1. Go to [Vagrant](https://www.vagrantup.com/) and download the latest version of Vagrant.
 2. Go to [VirtualBox](https://www.virtualbox.org/) and download the latest version of VirtualBox.
 3. Go to [Visual Studio Code](https://code.visualstudio.com/) and download the latest version of VSC.
 3. You also need a console emulator. My preference is [git](https://git-scm.com/). So download also the latest version of git.
 
 ### Create a vagrantfile.
 1. Create a folder. Give it the name LAMP. `mkdir LAMP`
 2. Make sure you work in your folder. `cd LAMP`
 3. Create a vagrantfile. You can chose a box [here](https://app.vagrantup.com/boxes/search). `vagrant init [NameBox]`
 4. Open the vagrantfile in VSC and set the network settings. You can chose which IP-Address you use. For example 192.168.33.10. `config.vm.network "private_network", ip: "192.168.33.10"`
 5. Set the folder settings. `config.vm.synced_folder ".", "/var/www/html", :nfs => { :mount_options => ["dmode=777", "fmode=666"] }`.
 This is were the drupal comes.
 6. The scripts come in provisioning. Provide a link in the vagant file 
     -  A script for your webserver and database `config.vm.provision "shell", path: "Webserver_database.sh"`  
     -  A script for your webapplication `config.vm.provision "shell", path: "webapplication.sh"`.  
     -  A script for your cockpit. `config.vm.provision "shell", path: "cockpit.sh"`.
 7. Go back to your git and navigatie into VSC. `code .`. Now VSC will open with the map you are using.
 8. Make three new files Webserver_database.sh, webapplication.sh and cockpit.sh

### Installation script for the webserver and database
 1.  Go inside your empty script and add the update and upgrade, this will update en upgrade the packages on your system.  
     -  `sudo apt-get update`
     -  `sudo apt-get -y upgrade`  
 2. Install git. `sudo apt-get install -y git`.
 3. Install apache2. `sudo apt-get install -y apache2`.
 4. Set passwords for mysql on root.  
     - `debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'`.
     - `debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'`.
 5. Install mysql and the client. `sudo apt-get install -y mysql-server mysql-client`.
 6. Install the databank
     - The script automatically removes the test database. Names the database, creates a user and gives him all rights. Don't forget to remove the brackets [].
      ```
        if [ ! -f /var/log/databasesetup ];
        then
        echo "DROP DATABASE IF EXISTS test" | mysql -uroot -proot
        echo "CREATE USER '[NameOfTheUser]'@'localhost' IDENTIFIED BY 'root'" | mysql -uroot -proot
        echo "CREATE DATABASE [NameDatabase]" | mysql -uroot -proot 
        echo "GRANT ALL ON [NameOfTheDatabase].* TO '[NameUser]'@'localhost'" | mysql -uroot -proot
        echo "flush privileges" | mysql -uroot -proot

        sudo touch /var/log/databasesetup
        fi
       ``` 
  7. Restart the webserver to admit the changes. `sudo service apache2 restart`.

### Change the VirtualHost in webserver and databae script
 1. This script ensures that everything can be overwritten
 ```
   # Aanpassen virtual host
      VHOST=$(cat <<EOF
     VirtualHost *:80>
      ServerName www.example.com
      ServerAdmin webmaster@localhost
      DocumentRoot /var/www/html
      <Directory /var/www/html>
          AllowOverride All
      </Directory>
      ErrorLog ${APACHE_LOG_DIR}/error.log
      CustomLog ${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>
  EOF
  )
  echo "${VHOST}" > /etc/apache2/sites-enabled/000-default.conf

  #Enable mod_rewrite
  sudo a2enmod rewrite

  # Restart the webserver 
  sudo service apache2 restart
```
 
### Installation script for the webapplication
 1. Install php. `sudo apt-get install php7.0`.
 2. Make a repository.  
     - `sudo add-apt-repository ppa:ondrej/php`.  
     - `sudo apt-get update`.
     - `sudo apt search php7`.
 3. Install all the extensions. You will need this for drupal:
     - `sudo apt-get install -y php7.0-curl`.
     - `sudo apt-get install -y php7.0-common`.
     - `sudo apt-get install -y php7.0-gd`.
     - `sudo apt-get install -y php7.0-mysql`.
     - `sudo apt-get install -y php7.0-libapache2-mod-php7.0`.
     - `sudo apt-get install -y php7.0-mbstring`.
     - `sudo apt-get install -y php7.0-mcrypt`.
     - `sudo apt-get install -y php7.0-xml`.
     - `sudo apt-get install -y php7.0-zip`.
 4. Restart the webserver to enable everything. `sudo service apache2 restart`.
 5. Enable mod rewrite. `suda a2enmod rewrite`.
 6. Integrate drupal:
     - Go to the home directory `cd ~`.
     - Install drupal here. `wget https://ftp.drupal.org/files/projects/drupal-8.8.4.tar.gz`.
     - Unpack the tar. `tar xzvf drupal-8.8.4.tar.gz`.
     - Go to the drupal directory. `cd drupal-8.8.4`.
     - rsync everything tor /var/www/html `sudo rsync -avz . /var/www/html`.
     - Make a folder named files inside /var/www/html/sites/default. `mkdir /var/www/html/sites/default/files`.
     - Replace default.settings.php to settings.php. `cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php`.
 7. place rights on the file:
     - `chmod 664 /var/www/html/sites/default/settings.php`.
     - `sudo chown -R :www-data /var/www/html/*`.
 
 ### Installation script for the cockpit
 1. Iinstall cockpit. `sudo apt-get install cockpit -y `.
 2. Start cockpit. `sudo systemctl start cockpit.socket`. 
 3. Enable cockpit. `sudo systemctl enable cockpit.socket`.
 
 ### Run drupal's installation script on the web
 1. Choose for the standard settings.
 2. Choose your own language.
 3. Click next. 
 4. Install the database with the data you used in the script.
 5. Choose country: ...
 6. Choose time: ...
 7. Choose a name for your website: 
 8. Now it will installed
 
     



 
 
