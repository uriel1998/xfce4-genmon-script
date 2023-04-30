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
#!/bin/bash



ICON="networkmanager"
IFACE=""
LAN_IP=""
WAN_IP=""

get_iface (){
    # Are we wifi/eth0/tunneled?
    # -m1 only matches the first - can put in a loop later to catch all
    # and if it's two, then they're separated by a space. So need to throw them 
    # into an array
    IFACE=$(netstat -nr | grep -m1 ^0.0.0.0 | awk -F " " '{print $8}')
#if (( $(sudo /sbin/ethtool wlan0 | grep -c "Link detected: yes") == 1 )); then
#   echo "wlp2s0"
#fi

#if (( $(sudo /sbin/ethtool eth0 | grep -c "Link detected: yes") == 1 )); then
#   echo "eth0"
#fi

}

wireless_info () {

    #wlan0     IEEE 802.11  ESSID:"insertSSIDhere-5g"  
     #     Mode:Managed  Frequency:5.745 GHz  Access Point: 50:C7:BF:CC:90:AE   
      #    Bit Rate=6 Mb/s   Tx-Power=15 dBm   
       #   Retry short limit:7   RTS thr:off   Fragment thr:off
        #  Power Management:off
         # Link Quality=63/70  Signal level=-47 dBm  
          #Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          #Tx excessive retries:0  Invalid misc:0   Missed beacon:0

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
    
    # if iface includes wlan0, then get wireless info

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


do_genmon (){


# do the genmon
echo "<icon>$ICON</icon><iconclick>xfce4-taskmanager</iconclick>"
echo "<txt> $CPU | $MEMUSAGE | $HD </txt><txtclick>xfce4-taskmanager</txtclick>"

    exit 0
}
