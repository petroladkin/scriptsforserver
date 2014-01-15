CWD=$(pwd)

echo "######"
echo "######    1 - create Joomla site"
echo "######    2 - create Wordpress site"
echo "######    3 - create Pelican site"

   	 # octopress
     # django


echo "######"
read -p "######  ?  Please choose command: " COMMAND
if [[ "$COMMAND" == "1" ]];
then
	$CWD/create_joomla.sh
elif [[ "$COMMAND" == "2" ]];
then
	$CWD/create_wordpress.sh
elif [[ "$COMMAND" == "3" ]];
then
	$CWD/create_pelican.sh
else
	echo "######   Error: selected wrong number"
fi
