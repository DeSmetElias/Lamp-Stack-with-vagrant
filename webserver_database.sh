# Beveiliging in ubuntu met appArmor -> automatisch. (selinux niet nodig)
# Updaten en upgraden van system packages
sudo apt-get update
sudo apt-get -y upgrade

# Installeren van git
sudo apt-get install -y git

# Installeren van apache
sudo apt-get install -y apache2

# Aanpassen virtual host
VHOST=$(cat <<EOF
<VirtualHost *:80>
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

# Stelt wachtwoorden van mysql in op 'root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

# Installeren van mysql en de client
sudo apt-get install -y mysql-server mysql-client

# Instellen databank
if [ ! -f /var/log/databasesetup ];
then
    echo "DROP DATABASE IF EXISTS test" | mysql -uroot -proot
    echo "CREATE USER 'elias'@'localhost' IDENTIFIED BY 'root'" | mysql -uroot -proot #NAAM USER
    echo "CREATE DATABASE lampdatabase" | mysql -uroot -proot #NAANM DATABANK
    echo "GRANT ALL ON lampdatabase.* TO 'elias'@'localhost'" | mysql -uroot -proot
    echo "flush privileges" | mysql -uroot -proot

    sudo touch /var/log/databasesetup
fi

# Herstart de webserver 
sudo service apache2 restart
