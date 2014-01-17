if [[ -z "$1" || -z "$2" || $1 == "-h" ]];
then
	echo "####################################"
	echo "####################################"
	echo ""
	echo "   ./add_config_group.sh <value_name> <value>"
	echo "      add value to /etc/pela/.config file"
	echo "        <value_name> : value name for create"
	echo "        <value>      : value for create"
	echo ""
	echo "####################################"
else
	if [[ "$(sed -n '/'$1='/p' /etc/pela/.config)" == "" ]];
	then
		echo "    $1=$2" >> /etc/pela/.config
	else
		echo "Warnig: value is exist"
	fi
fi
