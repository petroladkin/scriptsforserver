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
		ln -s /usr/local/scriptsforserver/run.sh /usr/local/bin/plss_run
	fi
	echo "######"
fi
echo "####################################"
