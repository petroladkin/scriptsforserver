CWD=$(pwd)

if [[ "$(cat /etc/pela/.config | grep 'pela_init_system')" == "" ]];
then
	echo "######"
	echo "######   init system"

	echo "######"
	echo "######   change root password"
	passwd

	echo "######"
	echo "######   add admin user"
	read -p "######  ?  Please enter admin name: " ADMIN_NAME
	adduser $ADMIN_NAME
	passwd $ADMIN_NAME

	echo "######"
	echo "######   configure system"
	sed -i '/^root\tALL=(ALL)/a '$ADMIN_NAME'\tALL=(ALL)\tALL' /etc/sudoers
	sed -i '/^#Port 22/c Port 22' /etc/ssh/sshd_config
	sed -i '/^#PermitRootLogin/c PermitRootLogin no' /etc/ssh/sshd_config
	sed -i '$a UseDNS no' /etc/ssh/sshd_config
	sed -i '$a AllowUsers '$ADMIN_NAME  /etc/ssh/sshd_config
	mkdir /etc/pela

	### 
	echo "[pela_init_system]:" > /etc/pela/.config
	echo "admin='$ADMIN_NAME'" >> /etc/pela/.config
	###

	echo "######"
	read -p "######  ?  Do you want to reboot the system [Y/n]: " REBOOT_YN
	if [[ "$REBOOT_YN" == "Y" || "$REBOOT_YN" == "y" || "$REBOOT_YN" == "" ]];
	then
		echo "######   restarting system..."
		shutdown -r now
	fi

	echo "######"
	read -p "######  ?  Do you want to continue to set up the system [Y/n]: " CONTINUE_YN
	if [[ "$CONTINUE_YN" != "Y" && "$CONTINUE_YN" != "y" && "$CONTINUE_YN" != "" ]];
	then
		exit 0;
	fi
fi

if [[ "$(cat /etc/pela/.config | grep 'pela_base_configure')" == "" ]];
then
	echo "######"
	echo "######   base configure system"

	echo "######"
	read -p "######  ?  Do you want to install FTP server [y/N]: " FTP_YN
	if [[ "$FTP_YN" == "Y" || "$FTP_YN" == "y" ]];
	then
		echo "######"
		echo "######   istall vsftpd"
		yum -y install vsftpd

		echo "######"
		echo "######   configure vsftpd"
		sed -i '/^#chroot_local_user=YES/c chroot_local_user=YES' /etc/vsftpd/vsftpd.conf
		read -p "######  ?  Do you want to disabled anonymous [Y/n]: " FTP_ANONYM_YN
		if [[ "$FTP_ANONYM_YN" == "Y" || "$FTP_ANONYM_YN" == "y" || "$FTP_ANONYM_YN" == "" ]];
		then
			sed -i '/^anonymous_enable=YES/c anonymous_enable=NO' /etc/vsftpd/vsftpd.conf
		fi

		echo "######"
		echo "######   restart vsftpd"
		chkconfig vsftpd on
		/etc/init.d/vsftpd restart
	fi

	echo "######"
	read -p "######  ?  Do you want to enable FireWall [Y/n]: " FIREWALL_YN
	if [[ "$FIREWALL_YN" == "Y" || "$FIREWALL_YN" == "y" || "$FIREWALL_YN" == "" ]];
	then
		echo "######"
		echo "######   enable FireWall"
		$CWD/firewall/disable.sh
		$CWD/firewall/enable.sh

		echo "######"
		read -p "######  ?  Do you want to install Knock server [Y/n]: " KNOCK_YN
		if [[ "$KNOCK_YN" == "Y" || "$KNOCK_YN" == "y" || "$KNOCK_YN" == "" ]];
		then
			echo "######"
			echo "######   istall knockd"
			yum -y install http://li.nux.ro/download/nux/dextop/el6/i386/knock-server-0.5-7.el6.nux.i686.rpm

			echo "######"
			echo "######   configure knockd"
			echo "[options]" 		>  /etc/knockd.conf
			echo "    UseSysLog" 	>> /etc/knockd.conf

			echo "######"
			read -p "######  ?  Do you want to configure SSH port [Y/n]: " KNOCK_SSH_YN
			if [[ "$KNOCK_SSH_YN" == "Y" || "$KNOCK_SSH_YN" == "y" || "$KNOCK_SSH_YN" == "" ]];
			then
				read -p "######  ?  Please enter knocked open SSH port: " KNOCK_SSH_PORT
				echo "[openSSH]"																>> /etc/knockd.conf
				echo "    sequence       = $KNOCK_SSH_PORT:udp, 1982:udp, 1985:udp, 2011:udp"	>> /etc/knockd.conf
				echo "    seq_timeout    = 5"													>> /etc/knockd.conf
				echo "    tcpflags       = syn,ack"												>> /etc/knockd.conf
				echo "    start_command = $CWD/firewall/openport.sh 22"							>> /etc/knockd.conf
				echo "    cmd_timeout   = 10"													>> /etc/knockd.conf
				echo "    stop_command  = $CWD/firewall/closeport.sh 22"						>> /etc/knockd.conf
        	else
				$CWD/firewall/openport.sh 22
				$CWD/firewall/saveconfig.sh
			fi
			if [[ "$FTP_YN" == "Y" || "$FTP_YN" == "y" ]];
			then
				echo "######"
				read -p "######  ?  Do you want to configure FTP port [Y/n]: " KNOCK_FTP_YN
				if [[ "$KNOCK_FTP_YN" == "Y" || "$KNOCK_FTP_YN" == "y" || "$KNOCK_FTP_YN" == "" ]];
				then
					read -p "######  ?  Please enter knocked open FPT port: " KNOCK_FTP_PORT
					echo "[openFTP]"																			>> /etc/knockd.conf
					echo "    sequence       = $KNOCK_FTP_PORT:udp, 1982:udp, 1985:udp, 2011:udp"				>> /etc/knockd.conf
					echo "    seq_timeout    = 5"																>> /etc/knockd.conf
					echo "    tcpflags       = syn,ack"															>> /etc/knockd.conf
       				echo "    start_command = $CWD/firewall/openport.sh 20; $CWD/firewall/openport.sh 21"		>> /etc/knockd.conf
        			echo "    cmd_timeout   = 10"																>> /etc/knockd.conf
        			echo "    stop_command  = $CWD/firewall/closeport.sh 20; $CWD/firewall/closeport.sh 21"		>> /etc/knockd.conf
        		else
					$CWD/firewall/openport.sh 20
					$CWD/firewall/openport.sh 21
					$CWD/firewall/saveconfig.sh
				fi
			fi

			echo "######"
			echo "######   restart knockd"
			chkconfig knockd on
			/etc/init.d/knockd restart
		else
			$CWD/firewall/openport.sh 22
			if [[ "$FTP_YN" == "Y" || "$FTP_YN" == "y" ]];
			then
				$CWD/firewall/openport.sh 20
				$CWD/firewall/openport.sh 21
			fi
			$CWD/firewall/saveconfig.sh
		fi

		echo "######"
		read -p "######  ?  Do you want to install Fail2Ban [Y/n]: " FAIL2BAN_YN
		if [[ "$FAIL2BAN_YN" == "Y" || "$FAIL2BAN_YN" == "y" || "$FAIL2BAN_YN" == "" ]];
		then
			echo "######"
			echo "######   istall fail2ban"
			yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
			yum -y install fail2ban

			echo "######"
			echo "######   configure fail2ban"

			echo "######"
			read -p "######  ?  Please enter email address to send a notification message: " FAIL2BAN_DEST_EMAIL
			FAIL2BAN_MASHINE_NAME=$(uname -n)

			echo "######"
			read -p "######  ?  Do you want to configure 'ssh-iptables' port [Y/n]: " FAIL2BAN_SSH_YN
			if [[ "$FAIL2BAN_SSH_YN" == "Y" || "$FAIL2BAN_SSH_YN" == "y" || "$FAIL2BAN_SSH_YN" == "" ]];
			then
				sed -i '/^\[ssh-iptables\]/,+5c \[ssh-iptables\]\n\nenable   = true\nfilter   = sshd\naction   = iptables[name=SSH, port=ssh, protocol=tcp]\n\t   sendmail-whois[name=SSH, dest=$FAIL2BAN_DEST_EMAIL, sender=fail2ban@$FAIL2BAN_MASHINE_NAME]' /etc/fail2ban/jail.conf
			fi

			if [[ "$FTP_YN" == "Y" || "$FTP_YN" == "y" ]];
			then
				echo "######"
				read -p "######  ?  Do you want to configure 'vsftpd-iptables' port [Y/n]: " FAIL2BAN_FTP_YN
				if [[ "$FAIL2BAN_FTP_YN" == "Y" || "$FAIL2BAN_FTP_YN" == "y" || "$FAIL2BAN_FTP_YN" == "" ]];
				then
					sed -i '/^\[vsftpd-iptables\]/,+5c \[vsftpd-iptables\]\n\nenable   = true\nfilter   = vsftpd\naction   = iptables[name=VSFTPD, port=ftp, protocol=tcp]\n\t   sendmail-whois[name=VSFTPD, dest=$FAIL2BAN_DEST_EMAIL, sender=fail2ban@$FAIL2BAN_MASHINE_NAME]' /etc/fail2ban/jail.conf
				fi
			fi

			echo "######"
			echo "######   restart fail2ban"
			chkconfig fail2ban on
			/etc/init.d/fail2ban restart
		fi
	fi

	### 
	echo "[pela_base_configure]:"     >>  /etc/pela/.config
	if [[ "$FTP_YN" == "Y" || "$FTP_YN" == "y" ]];
	then
		echo "vsftpd_install=YES" >> /etc/pela/.config
		if [[ "$FTP_ANONYM_YN" == "Y" || "$FTP_ANONYM_YN" == "y" || "$FTP_ANONYM_YN" == "" ]];
		then
			echo "vsftpd_disable_anonym=YES" >> /etc/pela/.config
		fi
	fi
	if [[ "$FIREWALL_YN" == "Y" || "$FIREWALL_YN" == "y" || "$FIREWALL_YN" == "" ]];
	then
		echo "firewall_enable=YES" >> /etc/pela/.config
		if [[ "$KNOCK_YN" == "Y" || "$KNOCK_YN" == "y" || "$KNOCK_YN" == "" ]];
		then
			echo "knockd_install=YES" >> /etc/pela/.config
			if [[ "$KNOCK_SSH_YN" == "Y" || "$KNOCK_SSH_YN" == "y" || "$KNOCK_SSH_YN" == "" ]];
			then
				echo "knockd_ssh_port=$KNOCK_SSH_PORT" >> /etc/pela/.config
			fi
			if [[ "$FTP_YN" == "Y" || "$FTP_YN" == "y" ]];
			then
				if [[ "$KNOCK_FTP_YN" == "Y" || "$KNOCK_FTP_YN" == "y" || "$KNOCK_FTP_YN" == "" ]];
				then
					echo "knockd_ftp_port=$KNOCK_FTP_PORT" >> /etc/pela/.config
				fi
			fi
		fi
		if [[ "$FAIL2BAN_YN" == "Y" || "$FAIL2BAN_YN" == "y" || "$FAIL2BAN_YN" == "" ]];
		then
			echo "fail2ban_install=YES" >> /etc/pela/.config
			echo "fail2ban_dest_email=$FAIL2BAN_DEST_EMAIL" >> /etc/pela/.config
			echo "fail2ban_mashine_name=$FAIL2BAN_MASHINE_NAME" >> /etc/pela/.config
			if [[ "$FAIL2BAN_SSH_YN" == "Y" || "$FAIL2BAN_SSH_YN" == "y" || "$FAIL2BAN_SSH_YN" == "" ]];
			then
				echo "fail2ban_ssh_enable=YES" >> /etc/pela/.config
			fi
			if [[ "$FTP_YN" == "Y" || "$FTP_YN" == "y" ]];
			then
				if [[ "$FAIL2BAN_FTP_YN" == "Y" || "$FAIL2BAN_FTP_YN" == "y" || "$FAIL2BAN_FTP_YN" == "" ]];
				then
					echo "fail2ban_vsftpd_enable=YES" >> /etc/pela/.config
				fi
			fi
		fi
	fi
	###

	echo "######"
	read -p "######  ?  Do you want to continue to set up the system [Y/n]: " CONTINUE_YN
	if [[ "$CONTINUE_YN" != "Y" && "$CONTINUE_YN" != "y" && "$CONTINUE_YN" != "" ]];
	then
		exit 0;
	fi
fi

if [[ "$(cat /etc/pela/.config | grep 'pela_configure')" == "" ]];
then
	echo "######"
	echo "######   create system"

	echo "######"
	echo "######    1 - create LEMP system"
	# echo "######    2 - create LEPP system"
	# echo "######    3 - create LAMP system"
	# echo "######    4 - create LAPP system"

	
   # 	 joomla
   # 	 wordpress
   # 	 pelican
   # 	 octopress
   #   django
   # VPNServer
   # MailServer
   # NAS
   #  samba
   #  transmision
   #  dropbox-downloader
   #  backup-scripts
   # Others



	echo "######"
	read -p "######  ?  Please choose command: " COMMAND
	if [[ "$COMMAND" == "1" ]];
	then
		cd $CWD/lemp
		$CWD/lemp/install.sh

		### 
		echo "[pela_configure]:" >> /etc/pela/.config
		echo "lemp_install=YES" >> /etc/pela/.config
		###
	# elif [[ "$COMMAND" == "2" ]];
	# then
	# 	echo "######   Sorry: coming soon"
	# elif [[ "$COMMAND" == "3" ]];
	# then
	# 	echo "######   Sorry: coming soon"
	# elif [[ "$COMMAND" == "4" ]];
	# then
	# 	echo "######   Sorry: coming soon"
	else
		echo "######   Error: selected wrong number"
	fi

	echo "######"
	read -p "######  ?  Do you want to continue to set up the system [Y/n]: " CONTINUE_YN
	if [[ "$CONTINUE_YN" != "Y" && "$CONTINUE_YN" != "y" && "$CONTINUE_YN" != "" ]];
	then
		exit 0;
	fi
fi

if [ "$(cat /etc/pela/.config | grep 'lemp_install')" != "" ]
then
	echo "######"
	echo "######   it is LEMP system"

	cd $CWD/lemp
	$CWD/lemp/run.sh
fi
