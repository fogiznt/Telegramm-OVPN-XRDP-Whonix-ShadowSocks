#!/bin/bash
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
DEFAULT='\033[0m'

echo -n -e "${DEFAULT}Обновление списка пакетов ${DEFAULT}" & echo -e ${GREEN} $(apt update 2>/dev/null | grep packages | cut -d '.' -f 1 | tr -cd '[[:digit:]]') "${DEFAULT} пакетов могут быть обновлены."
echo -e "Установка пакетов: "

echo -n -e "               shadowsocks-libev " & echo -n $(apt install shadowsocks-libev -y >&- 2>&-)
if [ "$(dpkg --get-selections shadowsocks-libev | awk '{print $2}')" = "install" ]; then echo -e "${GREEN}OK${DEFAULT}"; else echo -e "${RED}ОШИБКА, попробуйте установить данный пакет самостоятельно -${GREEN} apt install shadowsocks-libev ${DEFAULT}" ;fi

echo -n -e "               rng-tools " & echo -n $(apt install rng-tools -y >&- 2>&-)
if [ "$(dpkg --get-selections rng-tools | awk '{print $2}')" = "install" ]; then echo -e "${GREEN}OK${DEFAULT}"; else echo -e "${RED}ОШИБКА, попробуйте установить данный пакет самостоятельно -${GREEN} apt install rng-tools ${DEFAULT}" ;fi
rngd -r /dev/urandom

echo -n -e "               pip " & echo -n $(apt install pip -y >&- 2>&-)
if [ "$(dpkg --get-selections pip | awk '{print $2}')" = "install" ]; then echo -e "${GREEN}OK${DEFAULT}"; else echo -e "${RED}ОШИБКА, попробуйте установить данный пакет самостоятельно -${GREEN} apt install pip ${DEFAULT}" ;fi

pip install pytelegrambotapi

echo -n -e "               jq " & echo -n $(apt install jq -y >&- 2>&-)
if [ "$(dpkg --get-selections jq | awk '{print $2}')" = "install" ]; then echo -e "${GREEN}OK${DEFAULT}"; else echo -e "${RED}ОШИБКА, попробуйте установить данный пакет самостоятельно -${GREEN} apt install jq ${DEFAULT}" ;fi

echo -n -e "               screen " & echo -n $(apt install screen -y >&- 2>&-)
if [ "$(dpkg --get-selections screen | awk '{print $2}')" = "install" ]; then echo -e "${GREEN}OK${DEFAULT}"; else echo -e "${RED}ОШИБКА, попробуйте установить данный пакет самостоятельно -${GREEN} apt install screen ${DEFAULT}" ;fi
#screen -dmS ServerBot python3 /root/bot.py
#screen -dmS ServerBot python3 /etc/profile.d/ssh-telegram.sh

password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
cat >/etc/shadowsocks-libev/config.json <<EOF
{
    "server":["::1", "0.0.0.0"],
    "mode":"tcp_and_udp",
    "server_port":8388,
    "local_port":1080,
    "password":"$password",
    "timeout":60,
    "method":"chacha20-ietf-poly1305"
}
EOF

systemctl restart shadowsocks-libev.service >&- 2>&-
systemctl enable shadowsocks-libev.service >&- 2>&-

echo -n -e "ShadowSocks "
if ! [ "$(systemctl status shadowsocks-libev.service | grep -o "running" )" = "running" ]; then
echo -e "${RED}ошибка, не запущен /root/${DEFAULT}"
else
echo -e "${GREEN}запущен${DEFAULT}"
fi

#cd /
#cat >ssh_telegram <<EOF
##!/bin/bash
#echo "Порты SSH"
#cat /etc/ssh/sshd_config | grep "Port" | grep -v "GatewayPorts"
#echo -e "\nПодлкючённые пользователи"
#echo "|Юзер|Время коннекта|   ip пользователя   |"
#echo "|--------|----------------------------|-----------------------------|"
#for (( i=1;i<$(cat /var/log/auth.log | grep "Accepted password" | wc -l)+1;i++ ))
#do
#echo -n "|$(printf " %4s " $(cat /var/log/auth.log | grep -A1 "Accepted password" | grep "session opened" | sed -n ''$i'p' | awk '{print $11}'))|"
#echo -n "$(printf "%16s " "$(cat /var/log/auth.log | grep -A1 "Accepted password" | grep "session opened" | sed -n ''$i'p' | awk '{print $1,$2,$3}')")|"
#echo "$(printf "%17s    " $(cat /var/log/auth.log | grep "Accepted password" | sed -n ''$i'p' | awk '{print $11}'))|"
#done
#EOF

#cat >ports_telegram <<EOF
##!/bin/bash
#echo "| Протокол |   Порт  | Процесс |"
#for (( i=1;i<$(netstat -utlnp | grep -v "127.0.0" | grep -v -E "Active|Proto|tcp6|udp6" | wc -l)+1;i++ ))
#do
#echo -n  "|$(printf "%11s       " $(netstat -utlnp | grep -v "127.0.0" | grep -v -E "Active|Proto|tcp6|udp6" | sed -n ''$i'p' |awk '{print $1}') )|"
#echo -n  "$(printf "%6s " $(netstat -utlnp | grep -v "127.0.0" | grep -v -E "Active|Proto|tcp6|udp6" | sed -n ''$i'p' | awk '{print $4}' | sed 's/:/ /g' | awk '{print $2}') )|"
#echo -n  "$(printf "%11s    " $(netstat -utlnp | grep -v "127.0.0" | grep -v -E "Active|Proto|tcp6|udp6" | sed -n ''$i'p' |awk '{print $6}') )|"
#echo  "$(printf "%1s" "$(netstat -utlnp | grep -v "127.0.0" | grep -v -E "Active|Proto|tcp6|udp6" | sed -n ''$i'p' |awk '{print $7}' | sed 's/:/ /g' | sed 's/\// /g')")|"
#done
#for (( i=1;i<$(netstat -utlnp | grep -v "127.0.0" | grep -E "tcp6|udp6" | wc -l)+1;i++ ))
#do
#echo -n  "|$(printf "%11s      " $(netstat -utlnp | grep -v "127.0.0" | grep -E "tcp6|udp6" | sed -n ''$i'p' |awk '{print $1}'))|"
#echo -n  "$(printf "%6s " $(netstat -utlnp | grep -v "127.0.0" | grep -E "tcp6|udp6" | sed -n ''$i'p' | awk '{print $4}'| sed 's/://g'))|"
#echo -n  "$(printf "%11s " $(netstat -utlnp | grep -v "127.0.0" | grep -E "tcp6|udp6" | sed -n ''$i'p' |awk '{print $6}'))|"
#echo "$(printf "%10s" "$(netstat -utlnp | grep -v "127.0.0" | grep -E "tcp6|udp6" | sed -n ''$i'p' |awk '{print $7}' | sed 's/://g' | sed 's/\// /g')")|"
#done
#EOF

#cat >openvpn_telegram <<EOF
#echo -e "Список подключённых пользователей:\n"
#if [ "$(cat /etc/openvpn/status.log | grep 10.8.*)" = "" ];
#then echo -e "$Нет подключённых пользователей"
#else
#echo -e "|Локальный ip|   Аккаунт    |Время подключения|   ip пользователя   |${DEFAULT}"
#echo "|------------|--------------|-----------------|---------------------|"
#for (( i=1;i<$(cat /etc/openvpn/status.log | grep 10.8.8.* | wc -l)+1;i++ ))
#do
#echo -n "|$(printf " %10s " $(cat /etc/openvpn/status.log | grep "10.8.8.*" | sed -n ''$i'p'| sed 's/,/ /g' | awk '{print $1}'))|"
#echo -n "$(printf "%11s   " $(cat /etc/openvpn/status.log | grep "10.8.8.*" | sed -n ''$i'p'| sed 's/,/ /g' | awk '{print $2}'))|"
#echo -n "$(printf "%16s " "$(grep "$(cat /etc/openvpn/status.log | grep "10.8.8.*" | sed -n ''$i'p'| sed 's/,/ /g' | awk '{print $2}')" /etc/openvpn/status.log | sed -n '1p' | sed 's/,/ /g' | awk '{print $6,$7,$8}')")|"
#echo "$(printf "%17s    " $(cat /etc/openvpn/status.log | grep "10.8.8.*" |sed -n ''$i'p'| sed 's/,/ /g' | awk '{print $3}'| sed 's/:/ /g' | awk '{print $1}'))|"
#done
#fi
#EOF


ip=$(wget -qO- eth0.me)
echo "Ваш конфиг для ShadowSocks:"
echo "Server ip - $ip"
echo "Server Port - 8388"
echo "Password - $password"
echo "Encryption - chacha20-ietf-poly1305"

