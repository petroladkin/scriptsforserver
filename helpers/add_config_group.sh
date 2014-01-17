if [[ -z "$1" || $1 == "-h" ]];
then
	echo "####################################"
	echo "####################################"
	echo ""
	echo "   ./add_config_group.sh <group_name>"
	echo "      add group to /etc/pela/.config file"
	echo "        <group_name> : group name for create"
	echo ""
	echo "####################################"
else
	if [[ "$(sed -n '/'{$1}'/p' /etc/pela/.config)" == "" ]];
	then
		echo "{$1}" >> /etc/pela/.config
	else
		echo "Warnig: group is exist"
	fi
fi