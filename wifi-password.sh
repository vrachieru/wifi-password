#!/bin/bash

IFS=$'\n'

getOS() {
    case "`uname -s`" in
        Darwin)
            OS_NAME='osx';;
        Linux)
            OS_NAME='linux';;
        CYGWIN*|MINGW*|MSYS*)
            OS_NAME='windows';;
        *)
            OS_NAME='unknown';;
    esac

}

getNetworks() {
    if [ "$OS_NAME" == "linux" ]; then
        ls /etc/NetworkManager/system-connections
    elif [ "$OS_NAME" == "windows" ]; then
        netsh wlan show profiles | sed -n 's/\(.*Profile.*\) : \(.*\)/\2/p'
    fi
}

getPassword() {
    if [ "$OS_NAME" == "linux" ]; then
        sudo cat /etc/NetworkManager/system-connections/"$1" | sed -n 's/psk=\(.*\)/\1/p'
    elif [ "$OS_NAME" == "windows" ]; then
        netsh wlan show profiles name="$1" key=clear | sed -n 's/\(.*Key Content.*\) : \(.*\)/\2/p'
    fi
}

main() {
    getOS

    if [ $# -eq 0 ]; then
        networks=`getNetworks`
        maxNetworkLen=`printf "$networks" | wc -L`
        for n in $networks; do
             printf "%-${maxNetworkLen}s : %s\n" "$n" "`getPassword $n`"
         done
    elif [ $# -eq 1 ]; then
        printf "%s\n" "`getPassword "$1"`"
    else
        printf "Usage: wifi-password [ssid]\n"
    fi
}

main "$@"
exit 0
