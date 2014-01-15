CWD=$(pwd)

mysql_db=$1
mysql_user=$2
mysql_password=$3

echo "######"
echo "######   create MySQL db: $mysql_db for $mysql_user"

echo "GRANT ALL PRIVILEGES ON $mysql_db.* TO '$mysql_user'@'localhost' IDENTIFIED BY '$mysql_password';
GRANT ALL PRIVILEGES ON $mysql_db.* TO '$mysql_user'@'localhost.localdomain' IDENTIFIED BY '$mysql_password';
FLUSH PRIVILEGES;
" > /tmp/mysql_$mysql_user.sql
mysqladmin -u root -p create $mysql_db
mysql -u root -p < /tmp/mysql_$mysql_user.sql
rm -f /tmp/mysql_$mysql_user.sql