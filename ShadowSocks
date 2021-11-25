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

ip=$(curl check-host.net/ip 2>/dev/null) >&- 2>&-
echo "Ваш конфиг для ShadowSocks:"
echo "Server ip - $ip"
echo "Server Port - 8388"
echo "Password - $password"
echo "Encryption - chacha20-ietf-poly1305"

