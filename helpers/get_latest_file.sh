if [[ -z "$1" || -z "$2" || $1 == "-h" ]];
then
	echo "####################################"
	echo "####################################"
	echo ""
	echo "   ./get_latest_file.sh <url> <file_prefix> [<file_sufix>]"
	echo "      add value to /etc/pela/.config file"
	echo "        <url>         : url from get files"
	echo "        <file_prefix> : file name prefix"
	echo "        <file_sufix>  : file name sufix"
	echo ""
	echo "      return <url_to_file>"
	echo ""
	echo "####################################"
else
	URL=$1
	NAME=$2
	if [[ -z "$3" ]];
	then
		echo $URL$(curl $URL | sed -n '/'$NAME'/p' | tr "\"" "\n" | sed -n '/^'$NAME'/p' | sed -n '$p')
	else
		SUFIX=$3
		echo $URL$(curl $URL | sed -n '/'$NAME'/p' | tr "\"" "\n" | sed -n '/^'$NAME'/p' | sed -n '/'$SUFIX'$/p' | sed -n '$p')
	fi
fi



