#!/bin/bash

function newServer {
sudo apt-get update
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential
sudo apt-get install -y nginx
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y python-certbot-nginx
sudo npm install pm2 -g
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp /home/$USER
}

function clearDomains {
sudo rm /etc/nginx/sites-enabled/default 
}

function addDomains {
echo "NOTICE: Your dns must point to your ip address before this can work!"
echo "
    A Record @ StaticIP
    CNAME Record * domain.com
    CNAME Record www domain.com
"
echo ""
echo "Enter domain (example.com):"
read domain
echo "Enter port (8000):"
read port

sudo systemctl stop nginx
sudo tee /etc/nginx/sites-enabled/default > /dev/null << EOL
	server {
	       listen         80;
	       server_name    $domain www.$domain;
	       return         301 https://$server_name$request_uri;
	}
		server {
	        listen 443;
	        server_name $domain www.$domain;
	        ssl on;
	        ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
	        ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
	        ssl_session_timeout 5m;
	        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	        ssl_prefer_server_ciphers on;
	        ssl_dhparam /etc/ssl/certs/$domain.pem;
	        ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
	location / {
	          proxy_set_header        Host $host;
	          proxy_set_header        X-Real-IP $remote_addr;
	          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarsudoded_for;
	          proxy_set_header        X-Forwarded-Proto $scheme;
	          proxy_set_header Upgrade $http_upgrade;
	          proxy_set_header Connection "upgrade";
	          proxy_pass http://localhost:$port;
	          proxy_read_timeout  90;
	}
	}
EOL
sudo openssl dhparam -out /etc/ssl/certs/$domain.pem 2048
sudo certbot certonly --standalone -d $domain -d www.$domain
sudo systemctl start nginx
}

function renewDomains {
sudo certbot renew
}

clear
while true
do
echo ""
echo ""
echo ""
echo "EVG31337 Server Script V1.0"
echo "---------------------------"
echo "1 | Setup New Server Software"
echo "2 | Clear Server Domains"
echo "3 | Add New Server Domain"
echo "4 | Renew Domains HTTPS"
echo "--|------------------------"
echo "0 | Exit"
echo "---------------------------"
read -r -p "Your Choice: " response

if [[ "$response" == "0" ]]
then
exit
fi

if [[ "$response" == "1" ]]
then
newServer
fi

if [[ "$response" == "2" ]]
then
clearDomains
fi

if [[ "$response" == "3" ]]
then
addDomains
fi

if [[ "$response" == "4" ]]
then
renewDomains
fi
done