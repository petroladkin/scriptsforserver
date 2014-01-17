echo "####################################"
echo "####################################"
if [[$1 == "--help"]];
then
	echo ""
	echo "   ./setup.sh [-h]"
	echo ""
	echo "      - h: print this help"
	echo ""
else
	echo "######"
	CWD=$(pwd)

	if [[ "$(cat /etc/issue | grep 'CentOS')" != "" ]];
	then
		yum -y install git
		cd /usr/local
		git clone https://github.com/petroladkin/scriptsforserver.git
	fi
	echo "######"
fi
echo "####################################"
