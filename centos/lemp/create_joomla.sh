CWD=$(pwd)

echo "######"
read -p "######  ?  Please enter web site URL: " WEB_URL

server_name=$WEB_URL
folder_name=$(echo $server_name | sed 's/\.//g' | cut -c 1-8)
mysql_db=$folder_name'_db'
mysql_user=$folder_name'_user'
mysql_password=$folder_name'_password'

echo "######"
echo "######   install php-apc wget unzip"
yum -y --enablerepo=remi install php-apc wget unzip

echo "######"
echo "######   create $folder_name directory"
mkdir -p /usr/share/nginx/html/$folder_name

if [[ ! -s ~/Joomla_3.2.0-Stable-Full_Package.zip ]];
then
    echo "######"
    echo "######   download Joomla"
    wget -P ~ http://joomlacode.org/gf/download/frsrelease/18838/86936/Joomla_3.2.0-Stable-Full_Package.zip
fi

echo "######"
echo "######   unzip joomla"
unzip ~/Joomla_3.2.0-Stable-Full_Package.zip -d /usr/share/nginx/html/$folder_name
chown -R nginx:nginx /usr/share/nginx/html/$folder_name
chmod -R 750 /usr/share/nginx/html/$folder_name

$CWD/../mysql/create_db.sh $mysql_db $mysql_user $mysql_password

echo "######"
echo "######   create nginx config"
echo "
server {
    listen      80;
    server_name $server_name www.$server_name;
    root /usr/share/nginx/html/$folder_name;
    if (\$http_host = \"www.$server_name\") {
        rewrite ^(.*)\$  http://$server_name\$1 permanent;
    }
    location / {
        root        /usr/share/nginx/html/$folder_name;
        access_log  /var/log/nginx/$folder_name.access.log;
        index       index.php index.html;
        if (!-e \$request_filename) {
            rewrite (/|\.php|\.html|\.htm|\.feed|\.pdf|\.raw|/[^.]*)\$ /index.php last;
            break;
        }
    }
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    location ~ \.php\$ {
        root           /usr/share/nginx/html/$folder_name;
        if (!-f \$request_filename) {
            rewrite  ^(.*)\$  /index.php last;
        }
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }
    location ~* ^.+\.(jpg|jpeg|gif|png|svg|js|css|mp3|ogg|mpe?g|avi|zip|gz|bz2?|rar)\$ {
        root        /usr/share/nginx/html/$folder_name;
        access_log  /var/log/nginx/$folder_name.access.log;
        error_page  404 = @fallback;
    }
    location ~* /(images|cache|media|logs|tmp)/.*\.(php|pl|py|jsp|asp|sh|cgi)$ {
        return 403;
        error_page 403 /403_error.html;
    }
}" > /etc/nginx/conf.d/$folder_name.conf
chown nginx:nginx /etc/nginx/conf.d/$folder_name.conf
chmod 644 /etc/nginx/conf.d/$folder_name.conf

echo "######"
echo "######   restart nginx php-fpm"
/etc/init.d/php-fpm restart
/etc/init.d/nginx restart

###
echo "loomla_site=$folder_name" >> /etc/pela/.config
echo "loomla_db_$folder_name=$mysql_db" >> /etc/pela/.config
echo "loomla_user_$folder_name=$mysql_user" >> /etc/pela/.config
echo "loomla_password_$folder_name=$mysql_password" >> /etc/pela/.config
###

echo "######"
echo "####################################"
echo "######    please visit to " $server_name
echo "######      and type next db settings:"
echo "######      db name: " $mysql_db
echo "######      db user: " $mysql_user
echo "######      db password: " $mysql_password
