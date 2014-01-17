if [[ -z "$1" || $1 == "-h" ]];
then
	echo "####################################"
	echo "####################################"
	echo ""
	echo "   ./read_value.sh <message>"
	echo "      read string value from console"
	echo "        <message> :        show message for read value"
	echo ""
	echo "      return: string value"
	echo ""
	echo "####################################"
else
	MESSAGE=$1
	read -p "$MESSAGE: " VALUE
	echo $VALUE
fi