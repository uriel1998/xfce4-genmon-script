#!/bin/bash


##############################################################################
# network_script by Steven Saus <steven@stevesaus.com> 30 April 2023
# Under the GPL license.
# Cribs significantly from several byobu scripts originally by 
# Dustin Kirkland <kirkland@canonical.com> for Canonical in 2008.
##############################################################################


# Network script for xfce-genmon panel plugin, etc.
# tun=🔒
# eth= ⚯ ☎ 🔗
# wifi=📡
# wlan = ⋤ 🛰 🗺📠
# 🔁🚦


IFACE=""
LAN_IP=""
WAN_IP=""
TUNNELED=""

get_iface (){
    # -m1 only matches the first - can put in a loop later to catch all
    IFACE=$(netstat -nr | grep -m1 ^0.0.0.0 | awk -F " " '{print $8}')
    # Are we wifi/eth0/tunneled?
    TUNNELED=$(netstat -nr | grep -m 1 ^0.0.0.0 | awk -F " " '{print $8}')
}




wireless_info () {
        #    wifi_quality: display wifi signal quality
    #    Copyright (C) 2008 Canonical Ltd.
    #    Authors: Dustin Kirkland <kirkland@canonical.com>
       iwconfig=`/sbin/iwconfig 2>/dev/null`
    bitrate=`echo "$iwconfig" | grep "Bit Rate." | sed -e "s/^.*Bit Rate.//" -e "s/ .*$//g"`
    [ -z "$bitrate" ] && exit 0
    quality=`echo "$iwconfig" | grep "Link Quality." | sed -e "s/^.*Link Quality.//" -e "s/ .*$//g" | awk -F/ '{printf "%.0f", 100*$1/$2}'`
    printf "$(color b C k)%s$(color -)$(color C k)%s,$(color -)$(color b C k)%s$(color -)$(color C k)%%$(color -) " "$bitrate" "Mbps" "$quality"
}

get_lan_ip (){
    LAN_IP=$(ip -4 addr show dev $IFACE | grep inet | awk '{print $2}' | cut -d '/' -f 1)
}

get_wan_ip_dig (){
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
                            echo "$WAN_IP"
                        fi
                    fi
                fi
            fi
        fi
    fi
}


main (){
    get_iface
    get_lan_ip "$IFACE"
    get_wan_ip_dig
    if [ "$WAN_IP" == "" ];then
        get_wan_ip_3rdparty
    fi


# format output here with emojis, color, xfce4 stuff (or plain for conky?)
    if [ "$QUIET" = 4 ];then
        if [ "$WAN_IP" != "" ];then
            echo "$IFACE - $LAN_IP : $WAN_IP"
            exit 0
        else
            echo "Offline ..."
            exit 99
        fi
    fi
    exit 0
}


main
