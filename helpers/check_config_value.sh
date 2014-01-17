if [[ -z "$1" || $1 == "-h" ]];
then
	echo "####################################"
	echo "####################################"
	echo ""
	echo "   ./check_config_value.sh <value_name>"
	echo "      check value from /etc/pela/.config file"
	echo "        <value_name> : value name to check"
	echo ""
	echo "      return: 'YES'/'NO'"
	echo ""
	echo "####################################"
else
	if [[ "$(sed -n '/'$1='/p' /etc/pela/.config)" == "" ]];
	then
		echo "NO"
	else
		echo "YES"
	fi
fi