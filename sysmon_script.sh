#!/bin/bash

##############################################################################
# sysmon_script by Steven Saus <steven@stevesaus.com> 30 April 2023
# System monitor script for use with xfce4-genmon panel applet 
# (https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin)
# Released under the GPL license.
# Cribs significantly from other genmon scripts (including the default example)
# as well as these: 
# https://github.com/almaceleste/xfce4-genmon-scripts
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
    #https://stackoverflow.com/a/52751050
    CPU_RAW=$(top -b -n 3 -d 1  | head -3 | tail -1 | awk '{print $2}')
    CPU=$(printf "%.0f" $CPU_RAW)
    color=$(warn_colors $CPU $CPU_WARN $CPU_ALARM)
    printf "%s<span fgcolor='%s'>%s</span>" "${cpu_icon}" "${color}" "${CPU}"
}



get_memory (){
    # get % memory used
    MEMTOT=$(cat /proc/meminfo | grep MemTotal | awk '{printf ("% 0.1f", $2/1024000)}')
    MEMAVA=$(cat /proc/meminfo | grep MemAvailable | awk '{printf ("%0.1f", $2/1024000)}')
    MEM=$(echo "scale=2;100-($MEMAVA / $MEMTOT * 100)" | bc)
    MEMWARN=$(printf "%.0f" $MEM)
    color=$(warn_colors $MEMWARN $MEM_WARN $MEM_ALARM)
    printf "%s<span fgcolor='%s'>%s</span>" "${mem_icon}" "${color}" "${MEMWARN}"
}

get_temp (){
    # I'm using the package value here because it seems to be more reflective
    # of what bpytop reports
    # Core 0
    #TEMP=$(sensors | awk '/[Cc]ore 0/{print $3}')
    # PACKAGE 0
    TEMP=$(sensors | awk '/Package id 0/{print $4}'| tr -d "+")
    TEMPWARN=$(echo ${TEMP} |  sed 's!\.! !' | awk '{print $1}')
    color=$(warn_colors $TEMPWARN $TEMP_WARN $TEMP_ALARM)
    printf "%s <span fgcolor='%s'>%s</span>" "${temp_icon}" "${color}" "${TEMP}"    
}

get_load (){
    # if < 1 hr uptime, it mistakenly puts AVG on the line
    LOAD=$(uptime | tr -s " " | awk -F "average: " '{print $2}' | tr -d ",")
    LOAD1=$(printf "%0.f" $(echo $LOAD | awk '{print $1}'))
    # only really want 1m load for coloration
    color=$(warn_colors $LOAD1 $LOAD_WARN $LOAD_ALARM)
    printf "%s<span fgcolor='%s'>%s</span>" "${load_icon}" "${color}" "${LOAD}"        
}

get_battery (){
    BATTERY=$(acpi -b |awk -F ": " '{print $2}'| awk -F "," '{print substr($1,1,1) $2}')
    BATTERY_VALUE=$(acpi -b |awk -F ": " '{print $2}'| awk -F " " '{print $2}' | tr -d "%" )
    BATTWARN=$(echo "scale=2;(100-$BATTERY_VALUE)" | bc)
    BATTWARN=$(printf "%.0f" $BATTWARN)
    color=$(warn_colors $BATTWARN $BATTERY_WARN $BATTERY_ALARM)
    printf "%s <span fgcolor='%s'>%s</span>" "${power_icon}" "${color}" "${BATTERY}"        
}

do_genmon (){
    # do the genmon
    echo "<icon>$ICON</icon><iconclick>xfce4-taskmanager</iconclick>"
    # build the text string
    echo "<txt>$(get_cpu)% $(get_memory)% $(get_temp) $(get_battery) $(get_load) </txt><txtclick>xfce4-taskmanager</txtclick>"

    exit 0    
}

do_genmon

