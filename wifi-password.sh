#!/bin/bash

IFS=$'\n'

getPlatform() {
    case "$(uname -s)" in
        Darwin)
            PLATFORM='osx';;
        Linux)
            PLATFROM='linux';;
        CYGWIN*|MINGW*|MSYS*)
            PLATFORM='windows';;
        *)
            PLATFORM='unknown';;
    esac
}

getNetworks() {
    if [ "$PLATFORM" == "windows" ]; then
        printf "`netsh wlan show profiles | sed -n 's/\(.*Profile.*\) : \(.*\)/\2/p'`"
    fi
}

getPassword() {
    if [ "$PLATFORM" == "windows" ]; then
        printf "`netsh wlan show profiles name="$1" key=clear | sed -n 's/\(.*Key Content.*\) : \(.*\)/\2/p'`"
    fi
}

main() {
    getPlatform

    if [ $# -eq 0 ]; then
        networks=`getNetworks`
        maxNetworkLen=`printf "$networks" | wc -L`
        for n in $networks; do
             printf "%-${maxNetworkLen}s : %s\n" "$n" "`getPassword $n`"
         done
    elif [ $# -eq 1 ]; then
        getPassword "$1"
    else
        printf "Usage: wifi-password [ssid]"
    fi
}

main "$@"
exit 0
