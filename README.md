# How to build a LAMP development environment in Vagrant
  > The LAMP development environment will consist of linux, apache, mysql and php. We use the content management framework drupal as a web application on our PHP application
 ### Software
 1. Surf naar [Vagrant](https://www.vagrantup.com/) en maak een account aan of log in.
 2. Download de nieuwste versie van [Vagrant](https://www.vagrantup.com/).
 3. Download de nieuwste versie van [VirtualBox](https://www.virtualbox.org/).
 4. Download een console emulator voorbeeld [ConEmu](https://conemu.github.io/en/TextSelection.html) of [git](https://git-scm.com/).
 
 ### Aanmaken vagrantfile (Zie uitgewerkt script.)
 1. Maak eerst een map aan. `mkdir __naamDirectory__`.
 2. Open de console emulator en ga in de map. `cd __naamDirectory__`.
 3. Maak de vagrantfile aan. `vagrant init "__naamBox"`. Alle boxen vind je [hier](https://app.vagrantup.com/boxes/search).
 4. Open de vagrantfile in visual studio code en stel de netwerk instellingen in. `config.vm.network "private_network", ip: "192.168.33.10"`.
 5. Stel de folder instellingen in. `config.vm.synced_folder ".", "/var/www/html", :nfs => { :mount_options => ["dmode=777", "fmode=666"] }`.
 6. Zorg dat de provision naar de juiste scripts leid.  
     -  Hierin staat alles voor de webserver en database `config.vm.provision "shell", path: "Webserver_database.sh"`  
     -  Hierin staat alles voor de webapplicatie `config.vm.provision "shell", path: "webapplication.sh"`.  
     -  Hierin staat alles over de cockpit. `config.vm.provision "shell", path: "cockpit.sh"`.

> De vagrant file is correct en hoef je niet verder meer te gebruiken.

### Instellen script voor de webserver en database
 1.  Update en upgrade de packages op jouw system.  
     -  `sudo apt-get update`
     -  `sudo apt-get -y upgrade`  
 2. Installeer git. `sudo apt-get install -y git`.
 3. Installeer apache2. `sudo apt-get install -y apache2`.
 4. Stel wachtwoorden van mysql in op root.  
     - `debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'`.
     - `debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'`.
 5. Installeer mysql en de client. `sudo apt-get install -y mysql-server mysql-client`.
 6. Instellen van de databank
     - Zorgt ervoor als de databank test al bestaat dat deze verwijdert wordt. Maak vervolgens een user aan met het wachtwoord root.  
     - De user krijgt alle rechten om aanpassingen te doen in de databank.
      ```
        if [ ! -f /var/log/databasesetup ];
        then
        echo "DROP DATABASE IF EXISTS test" | mysql -uroot -proot
        echo "CREATE USER 'elias'@'localhost' IDENTIFIED BY 'root'" | mysql -uroot -proot #NAAM USER
        echo "CREATE DATABASE lampdatabase" | mysql -uroot -proot #NAANM DATABANK
        echo "GRANT ALL ON lampdatabase.* TO 'elias'@'localhost'" | mysql -uroot -proot
        echo "flush privileges" | mysql -uroot -proot

        sudo touch /var/log/databasesetup
        fi
       ``` 
  7. Herstart vervolgens de webserver op de aanpassingen door te voeren. `sudo service apache2 restart`.
### Aanpassen VirtualHost
 1. Zorg ervoor dat alles kan overschreven worden door AllowOverride op All te zetten zie onderstaand script dat wordt uitgevoerd in `/etc/apache2/sites-enabled` in het bestand `000-default.conf`
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

  #inschakelen mod_rewrite
  sudo a2enmod rewrite

  # Herstart de webserver 
  sudo service apache2 restart
```
 
### Installatiescript voor de webapplicatie
 1. Installeer php. `sudo apt-get install php7.0`.
 2. Maak de repository voor php aan.  
     - `sudo add-apt-repository ppa:ondrej/php`.  
     - `sudo apt-get update`.
     - `sudo apt search php7`.
 3. Installeer de extensies:
     - `sudo apt-get install -y php7.0-curl`.
     - `sudo apt-get install -y php7.0-common`.
     - `sudo apt-get install -y php7.0-gd`.
     - `sudo apt-get install -y php7.0-mysql`.
     - `sudo apt-get install -y php7.0-libapache2-mod-php7.0`.
     - `sudo apt-get install -y php7.0-mbstring`.
     - `sudo apt-get install -y php7.0-mcrypt`.
     - `sudo apt-get install -y php7.0-xml`.
     - `sudo apt-get install -y php7.0-zip`.
 4. Herstart de webserver om de extensies te activeren. `sudo service apache2 restart`.
 5. Enable mod rewrite. `suda a2enmod rewrite`.
 6. Integreer drupal:
     - Ga naar de `cd ~`.
     - Plak hierin de link van drupal met wget. `wget https://ftp.drupal.org/files/projects/drupal-8.8.4.tar.gz`.
     - Pak deze tar uit. `tar xzvf drupal-8.8.4.tar.gz`.
     - Ga in deze map. `cd drupal-8.8.4`.
     - rsync alles naar /var/www/html `sudo rsync -avz . /var/www/html`.
     - Maak een map files aan in /var/www/html/sites/default. `mkdir /var/www/html/sites/default/files`.
     - Verplaats default.settings.php naar settings.php. `cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php`.
 7. Plaats rechten op de file en allesin html map:
     - `chmod 664 /var/www/html/sites/default/settings.php`.
     - `sudo chown -R :www-data /var/www/html/*`.
 
 ### Installatiescript voor de cockpit
 1. Installeer cockpit. `sudo apt-get install cockpit -y `.
 2. Start cockpit. `sudo systemctl start cockpit.socket`. 
 3. Enable cockpit. `sudo systemctl enable cockpit.socket`.
 
 ### Doorloop installatie script in drupal op web
 1. Kies voor de standaard instelling.
 2. Kies voor de Nederlandse taal.
 3. Klik vervolgens op door. 
 4. Installeer databank met gegevens.
 5. Kies land: België.
 6. Kies tijd: Paris.
 7. Kies naam website: lamp website in vagrant.
 8. Installeer de website.
 
> Lamp script is klaar en drupal site werkt.
 
     



 
 
