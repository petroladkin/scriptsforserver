if [[ -z "$1" || $1 == "-h" ]];
then
	echo "####################################"
	echo "####################################"
	echo ""
	echo "   ./check_config_group.sh <group_name>"
	echo "      check group from /etc/pela/.config file"
	echo "        <group_name> : group name to check"
	echo ""
	echo "      return: 'YES'/'NO'"
	echo ""
	echo "####################################"
else
	if [[ "$(sed -n '/'{$1}'/p' /etc/pela/.config)" == "" ]];
	then
		echo "NO"
	else
		echo "YES"
	fi
fi