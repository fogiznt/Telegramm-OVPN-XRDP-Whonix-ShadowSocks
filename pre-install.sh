#!/bin/bash
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
DEFAULT='\033[0m'


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
read -rp "" -e -i 22 port_1
echo -e "Введите пароль"
read password_1

echo "|   Сервер   |   ip адрес   |    порт ssh     |    Пароль от root   |"
echo "|------------|--------------|-----------------|---------------------|"
echo "|     1      |"
echo -n "$(printf " %10s" $ip)"
