if [[ -z "$1" || $1 == "-h" ]];
then
	echo "####################################"
	echo "####################################"
	echo ""
	echo "   ./read_yn.sh <message> [<default_value>]"
	echo "      read Y/N value from console"
	echo "        <message> :        show message for read value"
	echo "        <default_value> :  default select value - Y, y, N, n"
	echo ""
	echo "      return: 'YES'/'NO'"
	echo ""
	echo "####################################"
else
	MESSAGE=$1
	DEFAULT="[Y/n]"
	if [[ -n "$2" && ( "$2" == "n" || "$2" == "N" ) ]];
	then
		DEFAULT="[y/N]"
	fi
	read -p "$MESSAGE $DEFAULT: " VALUE_YN
	if [[ "$VALUE_YN" == "" ]];
	then
		if [[ "$DEFAULT" = "[Y/n]" ]];
		then
			echo "YES"
		else
			echo "NO"
		fi
	else
		if [[ "$VALUE_YN" == "Y" || "$VALUE_YN" == "y" ]];
		then
			echo "YES"
		else
			echo "NO"
		fi
	fi
fi