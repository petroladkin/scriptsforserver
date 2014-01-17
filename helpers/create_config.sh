if [[ $1 == "-h" ]];
then
	echo "####################################"
	echo "####################################"
	echo ""
	echo "   ./create_config.sh"
	echo "      create /etc/pela/.config file"
	echo ""
	echo "####################################"
else
	if [[ -f "/etc/pela/.config" ]];
	then
		echo "Warnig: config file is exist"
	else
		mkdir /etc/pela
		echo "" > /etc/pela/.config
	fi
fi