# VPS Start Guide
#### By Colin Gidzinski
##### March 32/2017
-------------------------------------------------------------------------------


EC2 Setup & Connection
--------------------------------
1. Launch EC2 Instance Ubuntu Server HVM
2. Select size t2.micro (Free tier) or t2.nano
3. If you want to change default storage type click next
4. Create new SSH key pair (DONT LOSE THIS)
5. Launch!
6. Create Elastic IP and select the EC2 Instance you created earlier. (This gives you an ip address you can reassign from vps instance to instance)


EC2 Connection
--------------------------------
1. If Windows + PuTTY run PuTTYgen to create a putty version of you key pair (Load key.pem, save as key.ppk)
2. Input ubuntu@ElasticIPAddress as Host Name and under Connection>SSH>Auth Browse for the key.ppk
3. Save and connect


FTP Setup
--------------------------------
1. sudo apt-get update 
2. sudo apt-get install vsftpd
3. sudo nano /etc/vsftpd.conf

Uncomment
* write_enable=YES
* local_umask=022 
* chroot_local_user=YES 

Add
* allow_writeable_chroot=YES
* pasv_enable=Yes
* pasv_min_port=40000
* pasv_max_port=40100

4. Sudo nano /etc/shells

Add
* /usr/sbin/nologin

5. sudo service vsftpd restart
6. sudo useradd -m john -s /usr/sbin/nologin
7. sudo passwd john
8. Open EC2 Security Groups

Add
* Custom TCP Rule 21 0.0.0.0/0
* Custom TCP Rule 40000-40100 0.0.0.0/0 

9.Connect with username and password to IP on port 21


Domain Setup
--------------------------------
1. Setup Email redirection
2. Setup DNS

Add
* A Record			@		ElasticIP
* CNAME Record		*		domain.com
* CNAME Record		www		domain.com

**DNS Propigation May Take Up To 48 Hours**
**You can now use domain.com instead of your ElasticIP for FTP and PuTTY**


NodeJS Setup
--------------------------------
1. sudo apt-get install python-software-properties
2. curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
3. sudo apt-get install nodejs


NGINX Setup
--------------------------------
1. sudo apt-get install nginx
2. sudo systemctl start nginx
3. Open EC2 Security Groups

Add
* HTTP
* HTTPS


SSL Setup
--------------------------------
1. cd
2. sudo wget https://dl.eff.org/certbot-auto
3. sudo chmod a+x certbot-auto
4. ./certbot-auto certonly --standalone -d DOMAINNAME.com -d www.DOMAINNAME.com
5. sudo openssl dhparam -out /etc/ssl/certs/DOMAINNAME.com.pem 2048
6. cd ../../etc/nginx/sites-enabled
7. sudo nano default

Delete Everything (Hold Ctrl+k)
Add ** Replace DOMAINNAME.com with your domain name and PORT with your NODEJS Port **
```nginx	
	server {
	       listen         80;
	       server_name    DOMAINNAME.com www.DOMAINNAME.com;
	       return         301 https://$server_name$request_uri;
	}
		server {
	        listen 443;
	        server_name DOMAINNAME.com www.DOMAINNAME.com;
	        ssl on;
	        # Use certificate and key provided by Let's Encrypt:
	        ssl_certificate /etc/letsencrypt/live/DOMAINNAME.com/fullchain.pem;
	        ssl_certificate_key /etc/letsencrypt/live/DOMAINNAME.com/privkey.pem;
	        ssl_session_timeout 5m;
	        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	        ssl_prefer_server_ciphers on;
	        ssl_dhparam /etc/ssl/certs/DOMAINNAME.com.pem;
	        ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
	location / {
	          proxy_set_header        Host $host;
	          proxy_set_header        X-Real-IP $remote_addr;
	          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
	          proxy_set_header        X-Forwarded-Proto $scheme;
	          proxy_set_header Upgrade $http_upgrade;
	          proxy_set_header Connection "upgrade";
	          proxy_pass http://localhost:8082;
	          proxy_read_timeout  90;
	}
	}
```

8. sudo systemctl restart nginx
9. sudo crontab -e

ADD
* 52 0,12 * * * cd /home/ubuntu/ && ./certbot-auto renew --quiet --pre-hook "sudo systemctl stop nginx" --post-hook "sudo systemctl start nginx"


PM2 Setup
--------------------------------
1. sudo npm install pm2 -g
2. pm2 startup
3. sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu

PM2 Setup (Run Forever)
--------------------------------
1. Go to your node project
2. pm2 start server.js --name="PROJECT NAME"
3. Use these to control
* Start: pm2 start PROJECT NAME
* Stop: pm2 stop PROJECT NAME
* Restart: pm2 restart PROJECT NAME
* Reset Counters: pm2 reset PROJECT NAME
* List: pm2 list
* Monitor: pm2 monit
* Delete: pm2 delete PROJECT NAME

4. pm2 save


Misc
--------------------------------
* Edit File: sudo nano filename
* Save File: Ctrl-x, y, Enter
* Move Out Directory: cd ../
* Move Directory: cd directory
* List Directories: ls
* Git Clone: sudo git clone URL
* Git Pull: sudo git pull
* Autocomplete: [Tab]
* Paste: RightClick
* Copy: Highlight Text