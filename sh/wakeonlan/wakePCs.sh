#!/bin/bash

# this is a front end for wakeonlan
# it simply wakes up all PCs in the mac-list.conf file one by one.

mac_file="mac-list.conf"
# should we ping the PC to see if its awake? can also set per PC in conf by setting IP to None
do_ping=true

# how many pings to send before we give up( each ping waits 1 second )
timeout=10

# seconds to wait before closing the window
#   helpful when running from desktop shortcut so you can see the output
delay_before_close=3


wakepc()
{
    found=true
    wakeonlan $2
    tput setaf 4
    printf "%s" "Waking DredX-PC..."
    if [ "$do_ping" = true  ] && ! [ $3 = "None" ]; then
        i=0
        while ! ping -w 1 -c 1 -n $3 &> /dev/null
        do
            i=$((i+1))
            printf "%c" "."
            if (( i >= $timeout )); then
                found=false
                break
            fi
        done
        if [ "$found" = true ]; then
            tput setaf 5
            printf "\n%s\n"  "$1 is online"
        else
            tput setaf 9
            printf "\n%s\n" "$1 did not respond at ip $3, it probably isn't online."
        fi
    else
        tput setaf 3
        printf "\n%s\n"  "$1 should be online"
    fi
}

while read line; do
  # set forground color to white(resets on terminal close aka end of script)
  tput setaf 7

  # skip blank lines and comments
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ "$line" =~ ^\s*$ ]] && continue

  #convert line to array
  l=( $line )
  #send each element as argument to wakepc function
  wakepc ${l[0]} ${l[1]} ${l[2]}
done < "$mac_file"

sleep $delay_before_close
