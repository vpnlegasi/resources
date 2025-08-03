#!/bin/bash
# Color Validation
DF='\e[39m'
Bold='\e[1m'
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
CYAN='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
NC='\e[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\e[36m'
LIGHT='\033[0;37m'
MYIP=$(wget -qO- ipinfo.io/ip);
owner="vpnlegasi"
gitlink="https://raw.githubusercontent.com"
host="http://www.vpnlegasi.com"
sc=$(cat /home/.ver | awk '{print $1}')
int=$(cat /home/.int)
echo "Checking VPS"
clear





inst () {

admin=$( curl -s ${gitlink}/${owner}/ip-admin/main/access | grep $MYIP | awk '{print $2}' )
IZIN=$( curl -s ${gitlink}/${owner}/client-multiport-xtls/main/access | grep $MYIP | awk '{print $2}' )
IZIN1=$( curl -s ${gitlink}/${owner}/client-multiport-ws/main/access | grep $MYIP | awk '{print $2}' )

PERMISSION-XTLS () {
if [[ $MYIP = $admin || $MYIP = $IZIN ]]; then
	clear
	echo -e "${green}Permission Accepted...${NC}"
else
	clear
	echo -e "${RED}Permission Denied...${NC}"
	sleep 5
	menu
fi
}

PERMISSION-WS () {
if [[ $MYIP = $admin || $MYIP = $IZIN1 ]]; then
	clear
	echo -e "${green}Permission Accepted...${NC}"
else
	clear
	echo -e "${RED}Permission Denied...${NC}"
	sleep 5
	menu
fi
}

CEK="NOT ALLOWED"
CEK1="NOT ALLOWED"

[[ $MYIP = $admin || $MYIP = $IZIN ]] && CEK="ALLOWED"
[[ $MYIP = $admin || $MYIP = $IZIN1 ]] && CEK1="ALLOWED"

setfile() {
rm -rf .profile > /dev/null 2>&1
sc=$(cat /home/.ver | awk '{print $1}')
int=$(cat /home/.int)
cat << EOF >> /root/.profile
# ~/.profile: executed Custom shells by VPN Legasi.
	
	if [ "$BASH" ]; then
		if [ -f ~/.bashrc ]; then
			. ~/.bashrc
		fi
	fi

	mesg n || true
	rm -rf *.sh > /dev/null 2>&1
	wget ${gitlink}/${int}/${sc}/main/setup.sh && chmod +x setup.sh && ./setup.sh
EOF
}

cek_os_fix() {
    source /etc/os-release 2>/dev/null
    OS_ID=$ID
    OS_VER=$(echo "$VERSION_ID" | cut -d'.' -f1)

    if [[ $OS_ID == "debian" ]]; then
        if [[ $OS_VER -lt 11 ]]; then
            cp /etc/apt/sources.list /etc/apt/sources.list.backup 2>/dev/null
            cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian buster main
deb http://deb.debian.org/debian buster-updates main
deb http://security.debian.org/debian-security buster/updates main
EOF
            apt update -y >/dev/null 2>&1
        fi

    elif [[ $OS_ID == "ubuntu" ]]; then
        if [[ $OS_VER -lt 20 ]]; then
            cp /etc/apt/sources.list /etc/apt/sources.list.backup 2>/dev/null
            cat <<EOF > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu bionic main universe restricted multiverse
deb http://archive.ubuntu.com/ubuntu bionic-updates main universe restricted multiverse
deb http://security.ubuntu.com/ubuntu bionic-security main universe restricted multiverse
EOF
            apt update -y >/dev/null 2>&1
        fi
    fi
}

multiport-ws() {
	clear
	PERMISSION-WS

	echo -e "${green}YOUR CHOICE IS SCRIPT PREMIUM MULTIPORT-WS${NC}"
	echo -e "Begin downloading...."
	cek_os_fix
	sleep 3

	curl -s ${gitlink}/${owner}/multiport-ws/main/versi/main > /home/.ver
	echo "ohioscript" > /home/.int

	clear
	echo -e "Begin updating...."
	sleep 2

	sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
	sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

	clear
	echo ""
	sleep 1

	echo -e "[ ${green}NOTES${NC} ] After rebooting, system will auto continue installation"
	sleep 1
	echo -e "[ ${green}NOTES${NC} ] If you understand, press ENTER to continue"
	read

	echo -e "[ ${green}NOTES${NC} ] System will reboot in 3 seconds..."
	sleep 3

	setfile
	reboot
}

multiport-xtls() {
	clear
	PERMISSION-XTLS

	echo -e "${green}YOUR CHOICE IS SCRIPT PREMIUM MULTIPORT-XTLS${NC}"
	echo -e "Begin downloading...."
	cek_os_fix
	sleep 3

	curl -s ${gitlink}/${owner}/multiport-xtls/main/versi/main > /home/.ver
	echo "ohioscript" > /home/.int

	clear
	echo -e "Begin updating...."
	sleep 2

	sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
	sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

	clear
	echo ""
	sleep 1

	echo -e "[ ${green}NOTES${NC} ] After rebooting, system will auto continue installation"
	sleep 1
	echo -e "[ ${green}NOTES${NC} ] If you understand, press ENTER to continue"
	read

	echo -e "[ ${green}NOTES${NC} ] System will reboot in 3 seconds..."
	sleep 3

	setfile
	reboot
}

rm -rf /home/.ver >/dev/null 2>&1
rm -rf /home/.int >/dev/null 2>&1
clear -x

inf_o
echo -e "\033[0;34m----------------------------------\033[0m"
echo -e "\E[44;1;39mWELCOME TO AUTO SCRIPT VPN LEGASI \E[0m"
echo -e "\033[0;34m----------------------------------\033[0m"
echo -e "ALLOWED ARE GRANTED TO INSTALL"
echo -e "NOT ALLOWED PLEASE CONTACT @VPNLEGASI"
echo ""
echo -e "1) SCRIPT PREMIUM MULTIPORT-WS ($CEK1)"
echo -e "2) SCRIPT PREMIUM MULTIPORT-XTLS ($CEK)"
echo -e ""
echo -e "\033[0;34m----------------------------------\033[0m"
echo ""

read -p "SELECT THE OPTION NUMBER TO PROCEED INSTALL.
PRESS ANY KEY TO RETURN TO MENU: " opt
echo ""

case $opt in
1 | 01)
    clear
    multiport-ws
    ;;
2 | 02)
    clear
    multiport-xtls
    ;;
*)
    clear
    menu
    ;;
esac
}

inf_o() {
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)
OS=$(hostnamectl | grep "Operating System" | cut -d ' ' -f5-)
cname=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo)
cores=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
kern=$(uname -s)
ofaily=$(uname -r)

clear
echo -e "\033[0;34m-------------------------------------------\033[0m"
echo -e "\E[44;1;39m        USER VPS SYSTEM INFORMATION        \E[0m"
echo -e "\033[0;34m-------------------------------------------\033[0m"

printf "\033[0;34m%-24s\033[0m : %s\n" "VPS ISP"              "$ISP"
printf "\033[0;34m%-24s\033[0m : %s\n" "VPS Core"             "$cores"
printf "\033[0;34m%-24s\033[0m : %s\n" "VPS CPU Model"        "$cname"
printf "\033[0;34m%-24s\033[0m : %s\n" "VPS Kernel"           "$kern"
printf "\033[0;34m%-24s\033[0m : %s\n" "VPS OS Family"        "$ofaily"
printf "\033[0;34m%-24s\033[0m : %s\n" "VPS Operating System" "$OS"
printf "\033[0;34m%-24s\033[0m : %s\n" "VPS IP Address"       "$MYIP"

}

multiws() {
clear -x
echo -e "\033[0;34m-----------------------------------------------------------------\033[0m"
echo -e "\E[44;1;39m                   INFO Auto Script Multiport-WS                \E[0m"
echo -e "\033[0;34m-----------------------------------------------------------------\033[0m"
echo ""
curl ${gitlink}/${owner}/multiport-ws/main/port-info
echo ""
echo -e "\033[0;34m-----------------------------------------------------------------\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
menu
}

multiport-v2 () {
clear -x
echo -e "\033[0;34m------------------------------------------------------------\033[0m"
echo -e "\E[44;1;39m                INFO Auto Script MULTIPORT-XTLS            \E[0m"
echo -e "\033[0;34m------------------------------------------------------------\033[0m"
echo ""
curl ${gitlink}/${owner}/multiport-xtls/main/port-info
echo ""
echo -e "\033[0;34m-----------------------------------------------------------------\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
}

menu () {
clear -x
inf_o
echo -e ""
echo -e "\033[0;34m----------------------------------\033[0m"
echo -e "\E[44;1;39mWELCOME TO AUTO SCRIPT VPN LEGASI \E[0m"
echo -e "\033[0;34m----------------------------------\033[0m"
echo -e ""
echo -e "1) INFO SCRIPT PREMIUM MULTIPORT-WS"
echo -e "2) INFO SCRIPT PREMIUM MULTIPORT-XTLS"
echo -e "3) SCRIPT INSTALLATION"
echo -e ""
echo -e "\033[0;34m----------------------------------\033[0m"
echo ""
read -p "SELECT THE OPTION NUMBER TO VIEW SCRIRPT INFO
OR PRESS ANY KEY TO EXIT " opt
echo -e ""
case $opt in
1 | 01)
    clear
    multiws
    ;;
2 | 02)
    clear
    multiport-v2
    ;;
3 | 03)
    clear
    inst
    ;;
*)
    clear
    rm -rf *.sh > /dev/null 2>&1
    exit
    ;;
esac
}

menu