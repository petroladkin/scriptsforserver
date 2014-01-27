CWD=$(pwd)

RDVL="$CWD/../../helpers/read_value.sh"


echo "######"
echo "######    1 - create static site"
echo "######    2 - create Joomla site"

echo "######"
COMMAND=$($RDVL "######  ?  Please choose command")
if [[ "$COMMAND" == "1" ]];
then
	$CWD/create_static.sh
elif [[ "$COMMAND" == "2" ]];
then
	$CWD/create_joomla.sh
else
	echo "######   Error: selected wrong number"
fi
