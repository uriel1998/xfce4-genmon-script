#!/bin/bash

##############################################################################
# wan_detect, by Steven Saus 28 April 2023

#cpu=☢💻
#mem=✇📀💿
#temp=☮  🌡
#power=⚡
#load=⚙📜
#barometers=⚗
#🔋🐧💾📩💥⚠

get_cpu (){
    #https://www.baeldung.com/linux/get-cpu-usage
    cat /proc/stat |grep cpu |tail -1|awk '{print ($5*100)/($2+$3+$4+$5+$6+$7+$8+$9+$10)}'|awk '{print "CPU Usage: " 100-$1}'
    
    }

get_memory (){
    # get memory info
MEMTOT=$(cat /proc/meminfo | grep MemTotal | awk '{printf ("% 0.1f", $2/1024000)}')
MEMAVA=$(cat /proc/meminfo | grep MemAvailable | awk '{printf ("%0.1f", $2/1024000)}')
MEMUSAGE=$(free | grep Mem | awk '{printf("%02d",  $3/$2 * 100.0)}')
MEMUSAGE2=$(echo "$MEMTOT GB in use")
MEMUSED=$(echo "scale=2;($MEMTOT - $MEMAVA)" | bc)
TOPMEM=$(ps aux --no-headers | awk '{print $4 " "  $11}' | sort -rn | head -n 5)
}

get_temp (){
    # MORE_INFO+="└─ Temperature: $(sensors | awk '/[Cc]ore\ 0/{print $3}')"
    }

get_load (){
    #CPULOAD=$(uptime | tr -s " " | cut -d' ' -f9-)
    #/usr/bin/iostat -c -k -z | head -4 | tail -1 | awk '{print $4}'
    }


main (){}
