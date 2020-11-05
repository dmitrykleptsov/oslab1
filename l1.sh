#!/bin/bash

check=$1

if [[ "$EUID" -ne 0 ]]; then
    echo sudo ./l1.sh
    exit 1
fi

if [[ $check = '' ]]; then
    $0 -h
fi

case "$check" in
"-h"|"--help")
    printf "
    Все доступные аргументы:\n
    \t-i - Вывод всех сетевых интерфейсов
    \t-o - Включение/отключение заданных интерфейсов
    \t-s - Установка IP/Mask/Gateway для определенного интерфейса
    \t-k - Убийство процесса по занимаемому порту
    \t-f - Отключение сетевого интерфейса по шаблону ip
    \t-n - Отображение сетевой статистики\n
    \t-a - Отключение всех сетевых интерфейсов";;

"-k")
    kill -9 $(lsof -t -i4:$2);; 
"-i")
    printf "Имя сетевого инт.\tMAC адрес\t\tIP адрес\t\tСкорость соединения\n"
    for i in $(ls /sys/class/net/)
    do
	printf "$i\t\t$(ifconfig $i | grep "ether" | awk '{print $2}')\t\t$(ifconfig $i | grep "inet" | awk '{print $2}')\t\t$(ifconfig $i | grep "RX packets" | awk '{print $6, $7}')\n"
    done;;
"-o")
    for (( i=2, j=3; i <= $#; i+=2, j+=2 ))
    do
	ip link set ${!j} ${!i}
    done;;
"-a")
    for i in $(ls /sys/class/net/)
    do
	ip link set $i down
    done;;
"-s")
    ip addr add $2/$3 dev $4
    ip route add default via $5;;
"-n")
    cat /proc/net/dev;;
"-f")
    d=$(ip a | grep $2 | awk '{print $9}')
    ip link set $d down;;
esac