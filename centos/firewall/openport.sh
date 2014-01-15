REJECT_RULE_NO=$(/sbin/iptables -L INPUT --line-numbers | grep 'REJECT' | awk '{print $1}')
/sbin/iptables -I INPUT $REJECT_RULE_NO -m state --state NEW -m tcp -p tcp --dport $1 -j ACCEPT