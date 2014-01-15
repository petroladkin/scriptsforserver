CWD=$(pwd)

echo "######"
echo "######   create LEMP system"

echo "######"
echo "######   install mysql mysql-server nginx php-fpm php-mysql"
yum -y install http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum -y install mysql mysql-server nginx
yum -y --enablerepo=remi install php-fpm php-mysql php-mcrypt phpmyadmin

echo "######"
echo "######   configure"

$CWD/../firewall/openport.sh 80
$CWD/../firewall/closeport.sh 22
$CWD/../firewall/saveconfig.sh

sed -i '/^;cgi.fix_pathinfo/c cgi.fix_pathinfo=0' /etc/php.ini
sed -i '/^user/c user = nginx' /etc/php-fpm.d/www.conf
sed -i '/^group/c group = nginx' /etc/php-fpm.d/www.conf
sed -i '/^http {/a server_names_hash_bucket_size 64;' /etc/nginx/nginx.conf

echo "######"
read -p "######  ?  Please enter blowfish_secret for PHPMyAdmin: " SECRET_CODE
sed -i "/blowfish_secret/c \$cfg['blowfish_secret'] = '$SECRET_CODE';" /usr/share/phpmyadmin/config.inc.php

mkdir /var/lib/php/session
rm -rf /usr/share/nginx/html
mkdir /usr/share/nginx/html

chown -R nginx:nginx /var/lib/php
chown -R nginx:nginx /usr/share/phpmyadmin
chown -R nginx:nginx /usr/share/nginx/html

echo "#
# The default server
#
server {
    listen       80 default_server;
    server_name  _;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    location /phpmyadmin {
        root   /usr/share/;
        index  index.php index.html index.htm;
        location ~ ^/phpmyadmin/(.+\.php)\$ {
            try_files     \$uri = 404;
            root          /usr/share/;
            fastcgi_pass  127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            include       fastcgi_params;
        }
        location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html))$ {
            root          /usr/share/;
        }
    }
    
    location /phpMyAdmin {
        rewrite ^/* /phpmyadmin last;
    }
    
    error_page  404              /404.html;
    location = /404.html {
        root   /usr/share/nginx/html;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    location ~ \.php$ {
        root           /usr/share/nginx/html;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }

    location ~ /\.ht {
        deny  all;
    }
}
" > /etc/nginx/conf.d/default.conf
chown nginx:nginx /etc/nginx/conf.d/default.conf
chmod 640 /etc/nginx/conf.d/default.conf

chkconfig mysqld on
chkconfig php-fpm on
chkconfig nginx on

echo "######"
echo "######   restart daemons"
/etc/init.d/mysqld restart
/etc/init.d/php-fpm restart
/etc/init.d/nginx restart

echo "######"
echo "######   configure mysql secure"
/usr/bin/mysql_secure_installation
