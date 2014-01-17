CWD=$(pwd)

PLATFORM=$(uname -i)
FILE_SUFIX=$(uname -m)

RDYN="$CWD/../../helpers/read_yn.sh"
RDVL="$CWD/../../helpers/read_value.sh"
ADCG="$CWD/../../helpers/add_config_group.sh"
ADCV="$CWD/../../helpers/add_config_value.sh"
CHCV="$CWD/../../helpers/check_config_value.sh"


echo "######"
WEB_URL=$($RDVL "######  ?  Please enter web site URL")
echo "######"
SECONDPORT_YN=$($RDYN "######  ?  Do you want§ to bind to second port")
if [[ "$SECONDPORT_YN" == "YES" ]];
then
    SECOND_PORT=$($RDVL "######  ?  Please enter second port")
fi

SERVER_NAME=$WEB_URL
FOLDER_NAME=$(echo $SERVER_NAME | sed 's/\.//g' | cut -c 1-8)
MYSQL_DB=$FOLDER_NAME'_db'
MYSQL_USER=$FOLDER_NAME'_user'
MYSQL_PASSWORD=$FOLDER_NAME'_password'

echo "######"
echo "######   install php-apc wget unzip"
yum -y --enablerepo=remi install php-apc wget unzip

echo "######"
echo "######   create $FOLDER_NAME directory"
mkdir -p /usr/share/nginx/html/$FOLDER_NAME

echo "######"
echo "######   download Joomla"
JOOMLA_URL=$(./get_latest_joomla.sh)
JOOMLA_FILE=$(echo $JOOMLA_URL | tr "/" "\n" | sed -n '$p')
if [[ ! -f ~/$JOOMLA_FILE ]]
then
    wget -P ~ $JOOMLA_URL
fi

echo "######"
echo "######   unzip joomla"
unzip ~/$JOOMLA_FILE -d /usr/share/nginx/html/$FOLDER_NAME
chown -R nginx:nginx /usr/share/nginx/html/$FOLDER_NAME
chmod -R 750 /usr/share/nginx/html/$FOLDER_NAME

$CWD/../mysql/create_db.sh $MYSQL_DB $MYSQL_USER $MYSQL_PASSWORD

echo "######"
echo "######   create nginx config"
echo "
server {
    listen      80;" > /etc/nginx/conf.d/$FOLDER_NAME.conf
if [[ "$SECONDPORT_YN" == "YES" ]];
then
    echo "   listen      "$SECOND_PORT";" >> /etc/nginx/conf.d/$FOLDER_NAME.conf
fi
echo "    server_name $SERVER_NAME www.$SERVER_NAME;
    root /usr/share/nginx/html/$FOLDER_NAME;
    if (\$http_host = \"www.$SERVER_NAME\") {
        rewrite ^(.*)\$  http://$SERVER_NAME\$1 permanent;
    }
    location / {
        root        /usr/share/nginx/html/$FOLDER_NAME;
        access_log  /var/log/nginx/$FOLDER_NAME.access.log;
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
        root           /usr/share/nginx/html/$FOLDER_NAME;
        if (!-f \$request_filename) {
            rewrite  ^(.*)\$  /index.php last;
        }
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }
    location ~* ^.+\.(jpg|jpeg|gif|png|svg|js|css|mp3|ogg|mpe?g|avi|zip|gz|bz2?|rar)\$ {
        root        /usr/share/nginx/html/$FOLDER_NAME;
        access_log  /var/log/nginx/$FOLDER_NAME.access.log;
        error_page  404 = @fallback;
    }
    location ~* /(images|cache|media|logs|tmp)/.*\.(php|pl|py|jsp|asp|sh|cgi)$ {
        return 403;
        error_page 403 /403_error.html;
    }
}" >> /etc/nginx/conf.d/$FOLDER_NAME.conf
chown nginx:nginx /etc/nginx/conf.d/$FOLDER_NAME.conf
chmod 644 /etc/nginx/conf.d/$FOLDER_NAME.conf

echo "######"
echo "######   restart nginx php-fpm"
/etc/init.d/php-fpm restart
/etc/init.d/nginx restart

if [[ "$($CHCV vsftpd_install)" == "YES" ]];
then
    useradd $FOLDER_NAME -g nginx -p $FOLDER_NAME -d /usr/share/nginx/html/$FOLDER_NAME
fi

$ADCG joomla_$FOLDER_NAME
$ADCV joomla_site_$FOLDER_NAME $FOLDER_NAME
if [[ "$SECONDPORT_YN" == "YES" ]];
then
    $ADCV joomla_second_port_$FOLDER_NAME $SECOND_PORT
fi
$ADCV joomla_db_$FOLDER_NAME $MYSQL_DB
$ADCV joomla_user_$FOLDER_NAME $MYSQL_USER
$ADCV joomla_password_$FOLDER_NAME $MYSQL_PASSWORD

echo "######"
echo "####################################"
echo "######    please visit to " $SERVER_NAME
echo "######      and type next db settings:"
echo "######      db name: " $MYSQL_DB
echo "######      db user: " $MYSQL_USER
echo "######      db password: " $MYSQL_PASSWORD
