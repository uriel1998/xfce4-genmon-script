# xfce4-genmon-script

Two scripts for [xfce4's genmon panel plugin](https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin) so that I could get some specific info on my top horizontal panel. 

See the screenshots (one is oriented for easier reading; this is designed to be 
horizontal layout) for an idea of what it should look like.  

These scripts crib significantly from several byobu scripts originally by 
Dustin Kirkland for Canonical in 2008, as well as [the genmon example script](https://docs.xfce.org/_export/code/panel-plugins/xfce4-genmon-plugin/start?codeblock=0) 
as well as scripts from [almaceleste](https://github.com/almaceleste/xfce4-genmon-scripts) and [xtonousou](https://github.com/xtonousou/xfce4-genmon-scripts) and 
[this StackOverflow answer](https://stackoverflow.com/a/52751050) for getting a 
simple human-readable CPU percentage.

Depends heavily on quite a few monitoring utilities, such as `sensors`, `acpi`, 
`iwconfig`, `dig`, `curl`, and `bc`.  

Features:

* Definable "warning" and "alert" values for pretty much every variable in 
`sysmon_script` with colorization to yellow and red.
* Automatic detection of VPN
* Determines WAN IP address through a cascading fallback of sites
* Uses emojis for inline "icons" so you can adjust the linesize easily.

Also could be used for conky, though you'd have to strip out the styling elements.
