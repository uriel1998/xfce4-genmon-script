#!/bin/bash

##############################################################################
# network_script by Steven Saus <steven@stevesaus.com> 30 April 2023
# Under the GPL license.
# Cribs significantly from several byobu scripts originally by 
# Dustin Kirkland <kirkland@canonical.com> for Canonical in 2008.
##############################################################################

# Network script for xfce-genmon panel plugin, etc.
TUN_ICON=🔒
ETH_ICON=☎
WLAN_ICON=📡
WAN_ICON=🛰

ICON="networkmanager"
IFACE=""
IFACE_INFO=""  # used for storing wireless link quality
IFACE_ICON=""
IFACE_IP=""
WAN_IP=""

get_iface(){
    # Are we wifi/eth0/tunneled?
    # this is in an array because network-manager WILL connect via multiple 
    # interfaces -- wired and wireless -- unless explicitly told not to
    mapfile -t IFACE < <(netstat -nr | grep ^0.0.0.0 | awk -F " " '{print $8}')
}

wireless_info() {
    # only called if wireless card (wlan0 by default) is detected.
    # returns link quality here only, but iwconfig does return a lot more
    # info if you're so interested.
    /sbin/iwconfig 2>/dev/null | grep "Link Quality" | sed -e "s/^.*Link Quality.//" -e "s/ .*$//g" | awk -F/ '{printf "%.0f", 100*$1/$2}'
}

get_lan_ip (){
    # Will return LAN IP4 address for interface used as first argument
    echo "$(ip -4 addr show dev "$1" | grep inet | awk '{print $2}' | cut -d '/' -f 1)"
}

get_wan_ip_dig (){
    # this is the much more intensive attempt to find the WAN address via 
    # various resolvers controlled by others. Obviously leaks data to the web.
    result=$(dig +short myip.opendns.com @resolver1.opendns.com)
    if [ -z "$result" ];then
        result=$(dig +short myip.opendns.com @resolver2.opendns.com)
        if [ -z "$result" ];then
            result=$(dig +short myip.opendns.com @resolver3.opendns.com)
            if [ -z "$result" ];then
                result=$(dig +short myip.opendns.com @resolver4.opendns.com)
            fi
        fi
    fi
    # last sanity check
    if [ -n "$result" ];then
        WAN_IP="$result"
    fi
}


get_wan_ip_3rdparty () {
    result=$(curl --silent ipecho.net/plain)
    if [ -n $result ]; then
        WAN_IP="$result"
    else
        result=$(curl --silent ident.me)
        if [ -n $result ]; then
            WAN_IP="$result"
        else
            result=$(curl --silent checkip.amazonaws.com)
            if [ -n $result ]; then
                WAN_IP="$result"
            else
                result=$(curl --silent ifconfig.me)
                if [ -n $result ]; then
                    WAN_IP="$result"
                else
                    result=$(curl --silent icanhazip.com)
                    if [ -n $result ]; then
                        WAN_IP="$result"
                    else
                        result=$(curl --silent ifconfig.co)
                        if [ -n $result ]; then
                            WAN_IP="$result"
                        fi
                    fi
                fi
            fi
        fi
    fi
}


do_genmon(){
    get_iface
    # for multiple connections 
    for ((i = 0; i < ${#IFACE[@]}; i++));do
        if [ "${IFACE[$i]}" == "wlan0" ];then
            IFACE_ICON[$i]="${WLAN_ICON}"
            IFACE_INFO[$i]=$(wireless_info "${IFACE[$i]}") 
            # this is where we'd add coloring for quality, will do later.
            # TODO            
        elif [ "${IFACE[$i]}" == "eth0" ];then
            IFACE_ICON[$i]="${ETH_ICON}"
            IFACE_INFO[$i]=""
        else [ "${IFACE[$i]}" == "tun0" ];then
            IFACE_ICON[$i]="${TUN_ICON}"
            IFACE_INFO[$i]=""
        fi
        IFACE_IP[$i]=$(get_lan_ip "${IFACE[$i]}")
    done
    # Now for the WAN IP
    get_wan_ip_dig
    if [ "$WAN_IP" == "" ];then
        get_wan_ip_3rdparty
    fi
    if [ "$WAN_IP" == "" ];then
        WAN_IP="Offline"
    fi
    # and now to build the string...

    echo "<txt>$(get_cpu)% $(get_memory)% $(get_load) $(get_temp)</txt><txtclick>xfce4-taskmanager</txtclick>"

 
 
echo "<icon>$ICON</icon><iconclick>nm-connection-editor</iconclick>"
echo "<txt> $CPU | $MEMUSAGE | $HD </txt><txtclick>xfce4-taskmanager</txtclick>"

    exit 0
}
