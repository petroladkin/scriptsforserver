echo "####################################"
echo "####################################"
echo "######"

CWD=$(pwd)

if [[ "$(cat /etc/issue | grep 'CentOS')" != "" ]];
then
cd $CWD/centos
$CWD/centos/run.sh
else
echo "######   Error: not supported linux system"
fi
echo "######"
echo "####################################"
