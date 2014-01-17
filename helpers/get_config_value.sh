if [[ -z "$1" || $1 == "-h" ]];
then
	echo "####################################"
	echo "####################################"
	echo ""
	echo "   ./get_config_value.sh <value_name>"
	echo "      check value from /etc/pela/.config file"
	echo "        <value_name> : value name to check"
	echo ""
	echo "      return: value"
	echo ""
	echo "####################################"
else
	if [[ "$(sed -n '/'$1='/p' /etc/pela/.config)" == "" ]];
	then
		echo ""
	else
		echo $(sed -n '/'$1='/p' /etc/pela/.config | tr "=" "\n" | sed -n '$p')
	fi
fi