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

#echo "Перед установкой загрузите торрент файл ОС для VirtualBox - просто перетащите его в терминал"
#read torrent_file
#scp -P $port_1 $torrent_file root@$ip_1:/root/

echo "Введите токен вашего первого бота"
read bot_token
echo "Введите id вашего аккаунта"
read telegram_id

cat >bot.py <<EOF
from subprocess import check_output
import telebot
import time
bot = telebot.TeleBot("$bot_token")#токен бота
user_id = $telegram_id #id вашего аккаунта
@bot.message_handler(content_types=["text"])
def main(message):
   if (user_id == message.chat.id): #проверяем, что пишет именно владелец
      comand = message.text  #текст сообщения
      try: #если команда невыполняемая - check_output выдаст exception
         bot.send_message(message.chat.id, check_output(comand, shell = True))
      except:
         bot.send_message(message.chat.id, "Invalid input") #если команда некорректна
if __name__ == '__main__':
    while True:
        try:#добавляем try для бесперебойной работы
            bot.polling(none_stop=True)#запуск бота
        except:
            time.sleep(10)#в случае падения

EOF

cat >ssh-telegram.sh <<EOF
USERID="$telegram_id"
KEY="$bot_token"
TIMEOUT="10"
URL="https://api.telegram.org/bot\$KEY/sendMessage"
DATE_EXEC="\$(date "+%d %b %Y %H:%M")"
TMPFILE='/tmp/ipinfo-\$DATE_EXEC.txt'
if [ -n "\$SSH_CLIENT" ]; then
        IP=\$(echo \$SSH_CLIENT | awk '{print \$1}')
        PORT=\$(echo \$SSH_CLIENT | awk '{print \$3}')
        HOSTNAME=\$(hostname -f)
        IPADDR=\$(hostname -I | awk '{print \$1}')
        curl http://ipinfo.io/\$IP -s -o \$TMPFILE
        CITY=\$(cat \$TMPFILE | jq '.city' | sed 's/"//g')
        REGION=\$(cat \$TMPFILE | jq '.region' | sed 's/"//g')
        COUNTRY=\$(cat \$TMPFILE | jq '.country' | sed 's/"//g')
        ORG=\$(cat \$TMPFILE | jq '.org' | sed 's/"//g')
        TEXT="\$DATE_EXEC: \${USER} logged in to \$HOSTNAME (\$IPADDR) from \$IP - \$ORG - \$CITY, \$REGION, \$COUNTRY on port \$PORT"
        curl -s --max-time \$TIMEOUT -d "chat_id=\$USERID&disable_web_page_preview=1&text=\$TEXT" \$URL > /dev/null
        rm \$TMPFILE
fi
EOF

scp -P $port_1 bot.py root@$ip_1:/root/
scp -P $port_1 ssh-telegram.sh root@$ip_1:/etc/profile.d/


rm -f bot.py ssh-telegram.sh

echo "Введите токен вашего второго бота"
read bot_token

cat >bot.py <<EOF
from subprocess import check_output
import telebot
import time
bot = telebot.TeleBot("$bot_token")#токен бота
user_id = $telegram_id #id вашего аккаунта
@bot.message_handler(content_types=["text"])
def main(message):
   if (user_id == message.chat.id): #проверяем, что пишет именно владелец
      comand = message.text  #текст сообщения
      try: #если команда невыполняемая - check_output выдаст exception
         bot.send_message(message.chat.id, check_output(comand, shell = True))
      except:
         bot.send_message(message.chat.id, "Invalid input") #если команда некорректна
if __name__ == '__main__':
    while True:
        try:#добавляем try для бесперебойной работы
            bot.polling(none_stop=True)#запуск бота
        except:
            time.sleep(10)#в случае падения

EOF

cat >ssh-telegram.sh <<EOF
USERID="$telegram_id"
KEY="$bot_token"
TIMEOUT="10"
URL="https://api.telegram.org/bot\$KEY/sendMessage"
DATE_EXEC="\$(date "+%d %b %Y %H:%M")"
TMPFILE='/tmp/ipinfo-\$DATE_EXEC.txt'
if [ -n "\$SSH_CLIENT" ]; then
        IP=\$(echo \$SSH_CLIENT | awk '{print \$1}')
        PORT=\$(echo \$SSH_CLIENT | awk '{print \$3}')
        HOSTNAME=\$(hostname -f)
        IPADDR=\$(hostname -I | awk '{print \$1}')
        curl http://ipinfo.io/\$IP -s -o \$TMPFILE
        CITY=\$(cat \$TMPFILE | jq '.city' | sed 's/"//g')
        REGION=\$(cat \$TMPFILE | jq '.region' | sed 's/"//g')
        COUNTRY=\$(cat \$TMPFILE | jq '.country' | sed 's/"//g')
        ORG=\$(cat \$TMPFILE | jq '.org' | sed 's/"//g')
        TEXT="\$DATE_EXEC: \${USER} logged in to \$HOSTNAME (\$IPADDR) from \$IP - \$ORG - \$CITY, \$REGION, \$COUNTRY on port \$PORT"
        curl -s --max-time \$TIMEOUT -d "chat_id=\$USERID&disable_web_page_preview=1&text=\$TEXT" \$URL > /dev/null
        rm \$TMPFILE
fi
EOF

scp -P $port_2 bot.py root@$ip_2:/root/
scp -P $port_2 ssh-telegram.sh root@$ip_2:/etc/profile.d/

echo -e "\nНачать установку?\nEnter - Да, Ctrl+C - отмена."
read value
if ! [ "$value" = "" ];then exit;fi
echo -e "${GREEN}Первый сервер${DEFAULT}"
f=1
while [ f=1 ]
do
ssh root@$ip_1 -p $port_1 "cd ~ && wget https://raw.githubusercontent.com/fogiznt/Telegramm-OVPN-XRDP-Whonix-ShadowSocks/main/openvpn-install.sh -O openvpn-install.sh --secure-protocol=TLSv1_2"
if [ "$(ssh root@$ip_1 -p $port_1 cat openvpn-install.sh | grep -o "RED" | sed -n '1p' )" = "RED" ];then break;else ssh root@$ip_1 -p $port_1 rm -f openvpn-install.sh;fi
done
ssh root@$ip_1 -p $port_1 "cd ~ && chmod +x openvpn-install.sh && ./openvpn-install.sh"

echo -e "${GREEN}Второй сервер${DEFAULT}"
f=1
while [ f=1 ]
do
ssh root@$ip_2 -p $port_2 "cd ~ && wget https://raw.githubusercontent.com/fogiznt/Telegramm-OVPN-XRDP-Whonix-ShadowSocks/main/openvpn-install.sh -O openvpn-install.sh --secure-protocol=TLSv1_2"
if [ "$(ssh root@$ip_2 -p $port_2 cat openvpn-install.sh | grep -o "RED" | sed -n '1p' )" = "RED" ];then break;else ssh root@$ip_2 -p $port_2 rm -f openvpn-install.sh;fi
done

ssh root@$ip_2 -p $port_2 "ip=\$(wget -qO- eth0.me) && cd ~ && chmod +x openvpn-install.sh && sed -i '43,70d;579,587d' openvpn-install.sh && sed -i 's/"redirect-gateway def1 bypass-dhcp"/route 255.255.255.0/g' openvpn-install.sh && sed -i 's/10.8.8.0/10.8.9.0/g' && ./openvpn-install.sh"

echo "Установление соединения между серверами."
cd /root/
scp -P $port_2 root@$ip_2:/root/client-1.ovpn /root/
text=$(cat /root/client-1.ovpn)
cat >/root/client-1.conf <<EOF
$text
EOF
scp -P $port_1 /root/client-1.conf root@$ip_1:/etc/openvpn/
ssh root@$ip_1 -p $port_1 "systemctl start openvpn@client-1"
