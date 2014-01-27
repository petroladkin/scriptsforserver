CWD=$(pwd)

PLATFORM=$(uname -i)
FILE_SUFIX=$(uname -m)

RDYN="$CWD/../helpers/read_yn.sh"
RDVL="$CWD/../helpers/read_value.sh"
CRCF="$CWD/../helpers/create_config.sh"
ADCG="$CWD/../helpers/add_config_group.sh"
ADCV="$CWD/../helpers/add_config_value.sh"
CHCG="$CWD/../helpers/check_config_group.sh"
CHCV="$CWD/../helpers/check_config_value.sh"
GTCV="$CWD/../helpers/get_config_value.sh"
GTLF="$CWD/../helpers/get_latest_file.sh"


BASE_INIT="NO"
if [[ ! -f "/etc/pela/.config" ]];
then
    BASE_INIT="YES"
else
    if [[ "$($CHCG init_system)" == "" || "$1" == "-f" ]];
    then
        BASE_INIT="YES"
    fi
fi


if [[ "$BASE_INIT" == "YES" ]];
then
    echo "######"
    echo "######   init system"

    if [[ ! -f "/etc/pela/.config" ]];
    then
        $CRCF
    fi

    if [[ "$($CHCG init_system)" == "NO" ]];
    then
        $ADCG init_system
    fi

    REBOT_SYSTEM="NO"

    CREATEADMIN_YN="NO"
    if [[ "$($CHCV change_root_password)" == "YES" ]];
    then
        CREATEADMIN_YN="YES"
    else
        echo "######"
        CHANGEROOTPASS_YN=$($RDYN "######  ?  Do you want to change password")
        if [[ "$CHANGEROOTPASS_YN" == "YES" ]];
        then
            echo "######"
            echo "######   change root password"
            passwd

            REBOT_SYSTEM="YES"

            $ADCV change_root_password yes           
        fi
    fi

    CREATEADMIN_YN="NO"
    if [[ "$($CHCV admin_name)" == "YES" ]];
    then
        CREATEADMIN_YN="YES"
    else
        echo "######"
        CREATEADMIN_YN=$($RDYN "######  ?  Do you want to create admin account")
        if [[ "$CREATEADMIN_YN" == "YES" ]];
        then
            echo "######"
            echo "######   add admin user"
            ADMIN_NAME=$($RDVL "######  ?  Please enter admin name")
            adduser $ADMIN_NAME
            passwd $ADMIN_NAME

            echo "######"
            echo "######   configure system"
            sed -i '/^root\tALL=(ALL)/a '$ADMIN_NAME'\tALL=(ALL)\tALL' /etc/sudoers
            sed -i '/^#Port 22/c Port 22' /etc/ssh/sshd_config
            sed -i '$a UseDNS no' /etc/ssh/sshd_config
            sed -i '$a AllowUsers '$ADMIN_NAME  /etc/ssh/sshd_config

            REBOT_SYSTEM="YES"

            $ADCV admin_name $ADMIN_NAME
        fi
    fi

    if [[ $CREATEADMIN_YN == "YES" &&  "$($CHCV block_root_ssh)" == "NO" ]];
    then
        echo "######"
        BLOCKSSHROOT_YN=$($RDYN "######  ?  Do you want to block root access to ssh")
        if [[ "$BLOCKSSHROOT_YN" == "YES" ]];
        then
            echo "######"
            echo "######   blocking root to ssh"
            sed -i '/^#PermitRootLogin/c PermitRootLogin no' /etc/ssh/sshd_config

            $ADCV block_root_ssh yes
        fi
    fi

    if [[ "$REBOT_SYSTEM" == "YES" ]];
    then
        echo "######"
        REBOOT_YN=$($RDYN "######  ?  Do you want to reboot the system")
        if [[ "$REBOOT_YN" == "YES" ]];
        then
            echo "######   restarting system..."
            shutdown -r now
        fi
    fi

    echo "######"
    CONTINUE_YN=$($RDYN "######  ?  Do you want to continue to set up the system")
    if [[ "$CONTINUE_YN" != "YES" ]];
    then
        exit 0
    fi
fi

if [[ "$($CHCG base_configure)" == "NO" || "$1" == "-f" ]];
then
    echo "######"
    echo "######   base configure system"

    if [[ "$($CHCG base_configure)" == "NO" ]];
    then
        $ADCG base_configure
    fi

    FTP_YN="NO"
    if [[ "$($CHCV vsftpd_install)" == "YES" ]];
    then
        FTP_YN="YES"
    else
        echo "######"
        FTP_YN=$($RDYN "######  ?  Do you want to install FTP server (vsftpd)")
        if [[ "$FTP_YN" == "YES" ]];
        then
            echo "######"
            echo "######   istall vsftpd"
            yum -y install vsftpd

            $ADCV vsftpd_install yes

            echo "######"
            echo "######   configure vsftpd"
            sed -i '/^#chroot_local_user=YES/c chroot_local_user=YES' /etc/vsftpd/vsftpd.conf

            echo "######"
            echo "######   restart vsftpd"
            chkconfig vsftpd on
            /etc/init.d/vsftpd restart
        fi
    fi

    if [[ $FTP_YN == "YES" && "$($CHCV vsftpd_disable_anonym)" == "NO" ]];
    then
        echo "######"
        FTP_ANONYM_YN=$($RDYN "######  ?  Do you want to disabled anonymous user for FTP")
        if [[ "$FTP_ANONYM_YN" == "YES" ]];
        then
            sed -i '/^anonymous_enable=YES/c anonymous_enable=NO' /etc/vsftpd/vsftpd.conf
            /etc/init.d/vsftpd restart

            $ADCV vsftpd_disable_anonym yes
        fi
    fi

    FIREWALL_YN="NO"
    if [[ "$($CHCV firewall_enable)" == "YES" ]];
    then
        FIREWALL_YN="YES"
    else
        echo "######"
        FIREWALL_YN=$($RDYN "######  ?  Do you want to enable FireWall")
        if [[ "$FIREWALL_YN" == "YES" ]];
        then
            echo "######"
            echo "######   enable FireWall"
            $CWD/firewall/disable.sh
            $CWD/firewall/enable.sh

            $CWD/firewall/openport.sh 22
            if [[ "$FTP_YN" == "YES" ]];
            then
                $CWD/firewall/openport.sh 20
                $CWD/firewall/openport.sh 21
            fi
            $CWD/firewall/saveconfig.sh

            $ADCV firewall_enable yes
        fi
    fi

    if [[ "$FIREWALL_YN" == "YES" ]];
    then
        KNOCK_YN="NO"
        if [[ "$($CHCV knockd_install)" == "YES" ]];
        then
            KNOCK_YN="YES"
        else
            echo "######"
            KNOCK_YN=$($RDYN "######  ?  Do you want to install Knock server (knockd)")
            if [[ "$KNOCK_YN" == "YES" ]];
            then
                echo "######"
                echo "######   istall knockd"
                echo $($GTLF http://li.nux.ro/download/nux/dextop/el6/$PLATFORM/ knock-server)
                yum -y install $($GTLF http://li.nux.ro/download/nux/dextop/el6/$PLATFORM/ knock-server)

                echo "######"
                echo "######   configure knockd"
                echo "[options]"      >  /etc/knockd.conf
                echo "    UseSysLog"  >> /etc/knockd.conf

                echo "######"
                echo "######   restart knockd"
                chkconfig knockd on
                /etc/init.d/knockd restart

                $ADCV knockd_install yes
            fi
        fi

        if [[ "$KNOCK_YN" == "YES" && "$($CHCV knockd_ssh_port)" == "NO" ]];
        then
            echo "######"
            KNOCK_SSH_YN=$($RDYN "######  ?  Do you want to configure knocking SSH port")
            if [[ "$KNOCK_SSH_YN" == "YES" ]];
            then
                echo "######"
                echo "######   configure knocking SSH port"
                KNOCK_SSH_PORT=$($RDVL "######  ?  Please enter knocked open SSH port")

                echo "[openSSH]"                                                              >> /etc/knockd.conf
                echo "    sequence       = $KNOCK_SSH_PORT:udp, 1982:udp, 1985:udp, 2011:udp" >> /etc/knockd.conf
                echo "    seq_timeout    = 5"                                                 >> /etc/knockd.conf
                echo "    tcpflags       = syn,ack"                                           >> /etc/knockd.conf
                echo "    start_command = $CWD/firewall/openport.sh 22"                       >> /etc/knockd.conf
                echo "    cmd_timeout   = 1000"                                               >> /etc/knockd.conf
                echo "    stop_command  = $CWD/firewall/closeport.sh 22"                      >> /etc/knockd.conf

                $CWD/firewall/closeport.sh 22
                $CWD/firewall/saveconfig.sh

                /etc/init.d/knockd restart

                $ADCV knockd_ssh_port $KNOCK_SSH_PORT
            fi
        fi

        if [[ "$KNOCK_YN" == "YES" && "$FTP_YN" == "YES" && "$($CHCV knockd_ftp_port)" == "NO" ]];
        then
            echo "######"
            KNOCK_FTP_PORT=$($RDYN "######  ?  Do you want to configure knocking FTP port")
            if [[ "$KNOCK_FTP_PORT" == "YES" ]];
            then
                echo "######"
                echo "######   configure knocking FTP port"
                KNOCK_FTP_PORT=$($RDVL "######  ?  Please enter knocked open FTP port")

                echo "[openFTP]"                                                                          >> /etc/knockd.conf
                echo "    sequence       = $KNOCK_FTP_PORT:udp, 1982:udp, 1985:udp, 2011:udp"             >> /etc/knockd.conf
                echo "    seq_timeout    = 5"                                                             >> /etc/knockd.conf
                echo "    tcpflags       = syn,ack"                                                       >> /etc/knockd.conf
                echo "    start_command = $CWD/firewall/openport.sh 20; $CWD/firewall/openport.sh 21"     >> /etc/knockd.conf
                echo "    cmd_timeout   = 10"                                                             >> /etc/knockd.conf
                echo "    stop_command  = $CWD/firewall/closeport.sh 20; $CWD/firewall/closeport.sh 21"   >> /etc/knockd.conf

                $CWD/firewall/closeport.sh 20
                $CWD/firewall/closeport.sh 21
                $CWD/firewall/saveconfig.sh

                /etc/init.d/knockd restart

                $ADCV knockd_ftp_port $KNOCK_FTP_PORT
            fi
        fi

        FAIL2BAN_YN="NO"
        if [[ "$($CHCV fail2ban_install)" == "YES" ]];
        then
            FAIL2BAN_YN="YES"
        else
            echo "######"
            FAIL2BAN_YN=$($RDYN "######  ?  Do you want to install Fail2Ban")
            if [[ "$FAIL2BAN_YN" == "YES" ]];
            then
                echo "######"
                echo "######   istall fail2ban"
                yum -y install $($GTLF http://pkgs.repoforge.org/rpmforge-release/ rpmforge-release rf.$FILE_SUFIX.rpm)
                yum -y install fail2ban

                echo "######"
                echo "######   configure fail2ban"

                echo "######"
                FAIL2BAN_DEST_EMAIL=$($RDVL "######  ?  Please enter email address to send a notification message")

                echo "######"
                echo "######   restart fail2ban"
                chkconfig fail2ban on
                /etc/init.d/fail2ban restart

                $ADCV fail2ban_install yes
                $ADCV fail2ban_dest_email $FAIL2BAN_DEST_EMAIL
                $ADCV fail2ban_mashine_name $(uname -n)
            fi
        fi

        FAIL2BAN_DEST_EMAIL=$($GTCV fail2ban_dest_email)
        FAIL2BAN_MASHINE_NAME=$($GTCV fail2ban_mashine_name)

        if [[ "$FAIL2BAN_YN" == "YES" && "$($CHCV fail2ban_ssh_enable)" == "NO" ]];
        then
            echo "######"
            FAIL2BAN_SSH_YN=$($RDYN "######  ?  Do you want to configure file2ban 'ssh-iptables' port")
            if [[ "$FAIL2BAN_SSH_YN" == "YES" ]];
            then
                echo "######"
                echo "######   configure file2ban 'ssh-iptables' port"
                sed -i '/^\[ssh-iptables\]/,+5c \[ssh-iptables\]\n\nenable   = true\nfilter   = sshd\naction   = iptables[name=SSH, port=ssh, protocol=tcp]\n\t   sendmail-whois[name=SSH, dest=$FAIL2BAN_DEST_EMAIL, sender=fail2ban@$FAIL2BAN_MASHINE_NAME]' /etc/fail2ban/jail.conf
                /etc/init.d/fail2ban restart

                $ADCV fail2ban_ssh_enable yes
            fi
        fi

        if [[ "$FAIL2BAN_YN" == "YES" && "$FTP_YN" == "YES" && "$($CHCV fail2ban_ftp_enable)" == "NO" ]];
        then
            echo "######"
            FAIL2BAN_FTP_YN=$($RDYN "######  ?  Do you want to configure file2ban 'vsftpd-iptables' port")
            if [[ "$FAIL2BAN_FTP_YN" == "YES" ]];
            then
                echo "######"
                echo "######   configure file2ban 'vsftpd-iptables' port"
                sed -i '/^\[vsftpd-iptables\]/,+5c \[vsftpd-iptables\]\n\nenable   = true\nfilter   = vsftpd\naction   = iptables[name=VSFTPD, port=ftp, protocol=tcp]\n\t   sendmail-whois[name=VSFTPD, dest=$FAIL2BAN_DEST_EMAIL, sender=fail2ban@$FAIL2BAN_MASHINE_NAME]' /etc/fail2ban/jail.conf
                /etc/init.d/fail2ban restart

                $ADCV fail2ban_ftp_enable yes
            fi
        fi
    fi

    echo "######"
    CONTINUE_YN=$($RDYN "######  ?  Do you want to continue to set up the system")
    if [[ "$CONTINUE_YN" != "YES" ]];
    then
        exit 0
    fi
fi

if [[ "$($CHCG system_configure)" == "NO" ]];
then
    echo "######"
    echo "######   create system"

    echo "######"
    echo "######    1 - create LEMP system"

    echo "######"
    COMMAND=$($RDVL "######  ?  Please choose command")
    if [[ "$COMMAND" == "1" ]];
    then
        cd $CWD/lemp
        $CWD/lemp/install.sh

        $ADCG system_configure
        $ADCV lemp_install yes
    else
        echo "######   Error: selected wrong number"
    fi

    echo "######"
    CONTINUE_YN=$($RDYN "######  ?  Do you want to continue to set up the system")
    if [[ "$CONTINUE_YN" != "YES" ]];
    then
        exit 0
    fi
fi

if [[ "$($CHCV lemp_install)" == "YES" ]];
then
    echo "######"
    echo "######   it is LEMP system"

    cd $CWD/lemp
    $CWD/lemp/run.sh
fi
