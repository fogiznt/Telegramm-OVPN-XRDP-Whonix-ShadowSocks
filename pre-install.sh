#!/bin/bash
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
DEFAULT='\033[0m'

if ! [ -e ~/.ssh/id_rsa.pub ] &! [ -e ~/.ssh/id_rsa ];then
echo -e "Перед установкой сгенерируйте ключи ssh - просто ${GREEN}нажмите Enter${DEFAULT}"
ssh-keygen -q -N ""
fi

echo -e "Цепочка будет состоять из 2-х серверов"

echo -e "${GREEN}Первый сервер${DEFAULT}"
echo -e "Введите ip"
read ip_1
echo -e "Введите порт ssh - по умолчанию 22"
read -rp "" -e -i 22 port_1
echo -e "Введите пароль"
read password_1

echo -e "${GREEN}Второй сервер${DEFAULT}"
echo -e "Введите ip"
read ip_2
echo -e "Введите порт ssh - по умолчанию 22"
read -rp "" -e -i 22 port_2
echo -e "Введите пароль"
read password_2
echo "| Сервер |      ip адрес       | порт ssh |    Пароль от root   |"
echo "|--------|---------------------|----------|---------------------|"
echo -n "|   1    |"
echo -n "$(printf "%18s   " $ip_1)"
echo -n "|$(printf " %6s   " $port_1)"
echo "|$(printf " %18s  " $password_1)|"

echo -n "|   2    |"
echo -n "$(printf "%18s   " $ip_2)"
echo -n "|$(printf " %6s   " $port_2)"
echo "|$(printf " %18s  " $password_2)|"

echo -e "${GREEN}Проверка подключения${DEFAULT}"
echo -e "Первый сервер - введите пароль"
ssh-copy-id root@$ip_1 >&- 2>&-
if [ "$(ssh root@$ip_1 -p $port_1 echo OK)" = "OK" ];then
echo -e "${GREEN}Подключение есть${DEFAULT}"
else echo -e "${RED}Не удалось подключиться, выход из программы${DEFAULT}" exit;fi

echo -e "Второй сервер - введите пароль"
ssh-copy-id root@$ip_2 >&- 2>&-
if [ "$(ssh root@$ip_2 -p $port_2 echo OK)" = "OK" ];then
echo -e "${GREEN}Подключение есть${DEFAULT}"
else echo -e "${RED}Не удалось подключиться, выход из программы${DEFAULT}" exit;fi

echo -e "\nНачать установку?\nEnter - Да, Ctrl+C - отмена."
read value
if ! [ "$value" = "" ];then exit;fi
echo -e "${GREEN}Первый сервер${DEFAULT}"
ssh root@$ip_1 -p $port_1 "cd ~ && wget https://raw.githubusercontent.com/fogiznt/Telegramm-OVPN-XRDP-Whonix-ShadowSocks/main/openvpn-install.sh -O openvpn-install.sh --secure-protocol=TLSv1 && chmod +x openvpn-install.sh && ./openvpn-install.sh"
echo -e "${GREEN}Второй сервре${DEFAULT}"
ssh root@$ip_2 -p $port_2 "cd ~ && wget https://raw.githubusercontent.com/fogiznt/Telegramm-OVPN-XRDP-Whonix-ShadowSocks/main/shadowsocks.sh && chmod +x shadowsocks.sh && ./shadowsocks.sh"
