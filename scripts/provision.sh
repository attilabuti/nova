#!/usr/bin/env bash

# Exit on error
set -e

hostname=$1
appPort=$2
mongodbUser=$3
mongodbPass=$4

echo "--- Import the public key used by the package management system ---"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 # MongoDB

echo "--- Create a list file for MongoDB ---"
echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list

echo "--- Add repo for latest stable Nginx ---"
sudo add-apt-repository -y ppa:nginx/stable

echo "--- Update package list ---"
sudo apt-get update

echo "--- Installing Base Packages ---"
sudo apt-get install -y curl git htop build-essential openssl libssl-dev

echo "--- Installing Nginx ---"
sudo apt-get -y install nginx

echo "--- Creating SSL certificate ---"
sudo mkdir /etc/nginx/ssl
sudo su -c "openssl req -newkey rsa:2048 -x509 -nodes -keyout /etc/nginx/ssl/$hostname.key -new -out /etc/nginx/ssl/$hostname.cert -subj /CN=$hostname -reqexts SAN -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf '[SAN]\nsubjectAltName=DNS:$hostname')) -sha256 -days 3650"

echo "--- Configuring Nginx ---"
# Remove default sites from Nginx
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

echo "server {
    listen 80;

    server_name mail.$hostname;

    location / {
        proxy_pass http://localhost:1080;
    }
}" > /etc/nginx/sites-available/maildev

echo "server {
    listen 80;
    listen 443 default ssl;

    server_name $hostname *.$hostname;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ssl_certificate /etc/nginx/ssl/$hostname.cert;
    ssl_certificate_key /etc/nginx/ssl/$hostname.key;

    location / {
        proxy_pass http://localhost:$appPort;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}" > /etc/nginx/sites-available/$hostname

# Make a symbolic link
sudo ln -s /etc/nginx/sites-available/maildev /etc/nginx/sites-enabled/maildev
sudo ln -s /etc/nginx/sites-available/$hostname /etc/nginx/sites-enabled/$hostname

sudo service nginx reload

echo "--- Installing Node.js 8.x ---"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get -y install nodejs

echo "--- Installing MongoDB ---"
sudo apt-get -y install mongodb-org

echo "--- Create MongoDB user ---"
mongo admin --eval "db.createUser({ user: '$mongodbUser', pwd: '$mongodbPass', roles: [ { role: 'root', db: 'admin' } ] });"

sudo service mongod stop
sudo sed -i 's/bindIp\: 127\.0\.0\.1/bindIp\: 0\.0\.0\.0/' /etc/mongod.conf
cat <<EOT >> /etc/mongod.conf
security:
  authorization: "enabled"
EOT
sudo service mongod start

echo "--- Installing PM2 ---"
sudo npm install -g pm2 --silent
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup upstart -u vagrant --hp /home/vagrant >/dev/null

echo "--- Installing MailDev ---"
sudo npm install -g maildev --silent

echo "--- Start MailDev ---"
sudo su vagrant -c "pm2 start maildev"
sudo su vagrant -c "pm2 save"

echo "--- All done! ---"