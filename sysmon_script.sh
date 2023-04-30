#!/bin/bash

##############################################################################
# wan_detect, by Steven Saus 28 April 2023

CPU=""
MEM=""
FREEMEM=""
TEMP=""
LOAD=""
IOWAIT=""
BAROMETERS=""

#cpu=☢💻
#mem=✇📀💿
#temp=☮  🌡
#power=⚡
#load=⚙📜
#barometers=⚗
#🔋🐧💾📩💥⚠

get_cpu (){
    #https://www.baeldung.com/linux/get-cpu-usage
    CPU=$(cat /proc/stat |grep cpu |tail -1|awk '{print ($5*100)/($2+$3+$4+$5+$6+$7+$8+$9+$10)}'|awk '{print 100-$1}')
}

get_memory (){
    # get % memory used
    MEMTOT=$(cat /proc/meminfo | grep MemTotal | awk '{printf ("% 0.1f", $2/1024000)}')
    MEMAVA=$(cat /proc/meminfo | grep MemAvailable | awk '{printf ("%0.1f", $2/1024000)}')
    MEMUSED=$(echo "scale=2;($MEMTOT - $MEMAVA)" | bc)

    # This is amount of memory used
    MEM=$(free | grep Mem | awk '{printf("%02d",  $3/$2 * 100.0)}')
}

get_temp (){
    # high 86, crit 100
    # Core 0
    #TEMP=$(sensors | awk '/[Cc]ore 0/{print $3}')
    # PACKAGE 0
    TEMP=$(sensors | awk '/Package id 0/{print $4}')
}

get_load (){
    LOAD=$(uptime | tr -s " " | cut -d' ' -f9- | tr -d ",")
    # iowait
    IOWAIT=$(/usr/bin/iostat -c -k -z | head -4 | tail -1 | awk '{print $4}')
}


do_genmon (){
    # do the genmon
    echo "<icon>$ICON</icon><iconclick>xfce4-taskmanager</iconclick>"
    echo "<txt> $CPU | $MEMUSAGE | $HD </txt><txtclick>xfce4-taskmanager</txtclick>"
    echo "<tool>-=CPU $CPULOAD=-
    $TOPCPU

    -=MEM: $MEMUSED of $MEMUSAGE2=-
    $TOPMEM

    -=HD usage: $HDUSED of $HDSIZE GB in use=-
    $TOPHD</tool>"

    exit 0    
}


get_cpu
get_memory
get_load
get_temp


