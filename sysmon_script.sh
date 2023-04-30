#!/bin/bash

##############################################################################
# wan_detect, by Steven Saus 28 April 2023
# Cribs from https://github.com/almaceleste/xfce4-genmon-scripts
# https://github.com/xtonousou/xfce4-genmon-scripts

# setting some defaults. Change as appropriate.
WARN=80
ALARM=95
CPU_WARN=$WARN
CPU_ALARM=$ALARM
MEM_WARN=$WARN
MEM_ALARM=$ALARM
TEMP_WARN=$WARN
TEMP_ALARM=$ALARM
BATTERY_WARN=$WARN
BATTERY_ALARM=$ALARM
LOAD_WARN=4
LOAD_ALARM=5

# setting icons
# first is for the plugin, rest are inline (and hence emojis)
ICON=utilities-system-monitor
cpu_icon=💻
mem_icon=🧠
temp_icon=🌡
power_icon=🔋
load_icon=📜
#barometers=⚗
#🐧💾📩💥⚠⚙☮✇📀💿  

# Resetting variables
CPU=""
MEM=""
FREEMEM=""
TEMP=""
LOAD=""
IOWAIT=""
BATTERY=""

warn_colors (){
    # pass in VALUE, WARN, ALARM values, returns color
    if [ $1 -gt $3 ];then
        color='red'
    elif [ $1 -gt $2 ];then
        color='yellow'
    else
        color='lightgrey'
    fi
    echo "$color"
}


get_cpu (){
    #https://www.baeldung.com/linux/get-cpu-usage
    CPU_RAW=$(cat /proc/stat |grep cpu |tail -1|awk '{print ($5*100)/($2+$3+$4+$5+$6+$7+$8+$9+$10)}'|awk '{print 100-$1}')
    CPU=$(printf "%.0f" $CPU_RAW)
    color=$(warn_colors $CPU $CPU_WARN $CPU_ALARM)
    printf "%s<span fgcolor='%s'>%s</span>" "${cpu_icon}" "${color}" "${CPU}"
}



get_memory (){
    # get % memory used
    MEMTOT=$(cat /proc/meminfo | grep MemTotal | awk '{printf ("% 0.1f", $2/1024000)}')
    MEMAVA=$(cat /proc/meminfo | grep MemAvailable | awk '{printf ("%0.1f", $2/1024000)}')
    MEM=$(echo "scale=2;($MEMTOT - $MEMAVA)" | bc)
    MEMWARN=$(printf "%.0f" $MEM)
    color=$(warn_colors $MEMWARN $MEM_WARN $MEM_ALARM)
    printf "%s<span fgcolor='%s'>%s</span>" "${mem_icon}" "${color}" "${MEM}"
}

get_temp (){
    # Core 0
    #TEMP=$(sensors | awk '/[Cc]ore 0/{print $3}')
    # PACKAGE 0
    TEMP=$(sensors | awk '/Package id 0/{print $4}'| tr -d "+" | awk -F "." "{print $1}")
    TEMPWARN=$(printf "%.0f" $TEMP)
    color=$(warn_colors $TEMPWARN $TEMP_WARN $TEMP_ALARM)
    printf "%s<span fgcolor='%s'>%s</span>" "${temp_icon}" "${color}" "${TEMP}"    
}

get_load (){
    LOAD=$(uptime | tr -s " " | cut -d' ' -f9- | tr -d ",")
    # iowait
    IOWAIT=$(/usr/bin/iostat -c -k -z | head -4 | tail -1 | awk '{print $4}')
    LOAD1=$(printf "%0.f" $(echo $LOAD | awk '{print $1}'))
    # only really want 1m load for coloration
    color=$(warn_colors $LOAD1 $LOAD_WARN $LOAD_ALARM)
    printf "%s<span fgcolor='%s'>%s</span>" "${load_icon}" "${color}" "${LOAD}"        
}

get_battery (){
    BATTERY=$(acpi -b |awk -F ": " '{print $2}'| awk -F "," '{print substr($1,1,1) $2}')
    BATTERY_VALUE=$(acpi -b |awk -F ": " '{print $2}'| awk -F " " '{print $2}' | tr -d "%" )
    BATTWARN=$(printf "%.0f" $BATTERY_VALUE)
    BATTERY_WARN=$(echo "scale=2;(100-$BATTERY_WARN)" | bc)
    BATTERY_ALARM=$(echo "scale=2;(100-$BATTERY_ALARM)" | bc) 
    color=$(warn_colors $BATTWARN $BATTERY_WARN $BATTERY_ALARM)
    printf "%s <span fgcolor='%s'>%s</span>" "${battery_icon}" "${color}" "${BATTERY}"        
}

do_genmon (){
    # do the genmon
    echo "<icon>$ICON</icon><iconclick>xfce4-taskmanager</iconclick>"
    # build the text string
    echo "<txt>$(get_cpu)% $(get_memory)% $(get_load) $(get_temp)</txt><txtclick>xfce4-taskmanager</txtclick>"

    exit 0    
}

do_genmon

