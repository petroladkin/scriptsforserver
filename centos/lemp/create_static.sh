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

echo "######"
echo "######   create $FOLDER_NAME directory"
mkdir -p /usr/share/nginx/html/$FOLDER_NAME

echo "######"
echo "######   create nginx config"
echo "
server {
    listen      80;" > /etc/nginx/conf.d/$FOLDER_NAME.conf
if [[ "$SECONDPORT_YN" == "YES" ]];
then
    echo "    listen      "$SECOND_PORT";" >> /etc/nginx/conf.d/$FOLDER_NAME.conf
fi
echo "    server_name $SERVER_NAME www.$SERVER_NAME;
    root /usr/share/nginx/html/$FOLDER_NAME;
    if (\$http_host = \"www.$SERVER_NAME\") {
        rewrite ^(.*)\$  http://$SERVER_NAME\$1 permanent;
    }
    location / {
        root        /usr/share/nginx/html/$FOLDER_NAME;
        access_log  /var/log/nginx/$FOLDER_NAME.access.log;
        index       index.html;
    }
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}" >> /etc/nginx/conf.d/$FOLDER_NAME.conf
chown nginx:nginx /etc/nginx/conf.d/$FOLDER_NAME.conf
chmod 644 /etc/nginx/conf.d/$FOLDER_NAME.conf

if [[ "$($CHCV firewall_enable)" == "YES" ]];
then
    $CWD/../firewall/openport.sh $SECOND_PORT
    $CWD/../firewall/saveconfig.sh
fi

echo "######"
echo "######   restart nginx php-fpm"
/etc/init.d/nginx restart

# if [[ "$($CHCV vsftpd_install)" == "YES" ]];
# then
#     # useradd $FOLDER_NAME -g nginx -p $FOLDER_NAME -d /usr/share/nginx/html/$FOLDER_NAME
# fi

$ADCG static_$FOLDER_NAME
$ADCV static_url_$FOLDER_NAME $SERVER_NAME
$ADCV static_home_$FOLDER_NAME $FOLDER_NAME
if [[ "$SECONDPORT_YN" == "YES" ]];
then
    $ADCV static_second_port_$FOLDER_NAME $SECOND_PORT
fi

echo "######"
echo "####################################"
echo "######    please upload files to /usr/share/nginx/html/" $FOLDER_NAME
echo "######      and visit to " $SERVER_NAME
