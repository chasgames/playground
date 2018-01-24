#!/bin/bash

echo "Congratulations for choosing the best linux distribution"
apt update -y
apt upgrade -y
apt-get install dialog htop denyhosts iotop iftop openssh-server vim sudo tree chrony curl wget man -y
source <(curl -s https://raw.githubusercontent.com/chasgames/EZ-Server-Provisioning/master/questions.sh)
if [ $cancel_catch -eq 1 ]; then
    echo "ABORT ABORT - You cancelled something"
    exit 1
fi
if [ $rootpw_choice != $rootpwconfirm_choice ]; then
    echo "ABORT ABORT - Root password mistype"
    exit 1
fi
echo $cancel_catch
echo $testing
echo $hostname_choice
echo $rootpw_choice
echo $rootpwconfirm_choice
echo $newusr_choice
echo $newusrpw_choice
echo "You have decided: $docker_choice"

    # First Update all packages -y for no interactive

    echo "Configuring packages"
    echo "Removing SSH Root Login"
    sed -i '/^PermitRootLogin[ \t]\+\w\+$/{ s//PermitRootLogin no/g; }' /etc/ssh/sshd_config
    # Configuring Chrony, way better than NTPd, much more reliable and stays in Sync.
    echo "Maybe add some time sources here"
    
if cat /etc/passwd | grep $newusr_choice >/dev/null; then
            echo "$newusr_choice exists!"
            exit 1
        else
            echo "root:$rootpw_choice" | chpasswd
            useradd -m $newusr_choice
            echo "$newusr_choice:$newusrpw_choice" | chpasswd
            usermod -aG sudo $newusr_choice
            [ $? -eq 0 ] && echo "User has been added to system.. oh and it's a sudo!" || echo "Failed to add a user!"
        fi

    hostnamectl set-hostname $hostname_choice

    # Need to restart SSH for root password to take affect.
    service ssh restart
    
    if [ $docker_choice == "yes" ]; then
        echo "installing Docker"
        apt install apt-transport-https ca-certificates software-properties-common python-pip -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        apt update
        apt install docker-ce -y
        usermod -aG docker $newusr_choice
        pip install docker-compose
    fi
    

    if [ $duo_choice == "yes" ]; then
        echo "installing Duo"
        echo 'deb http://pkg.duosecurity.com/Ubuntu xenial main' | tee /etc/apt/sources.list.d/duosecurity.list
		curl -s https://duo.com/APT-GPG-KEY-DUO | apt-key add -
		apt update -y
		apt install duo-unix
    fi
