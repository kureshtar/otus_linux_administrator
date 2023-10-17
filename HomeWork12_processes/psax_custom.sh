#!/bin/bash

#save in proc process list
proc=$(ls /proc | grep -E "^[0-9]+$")
clk_tck=$(getconf CLK_TCK)

(
echo "PID|TTY|STAT|TIME|COMMAND";
for pid in $proc; do
  #echo "$pid"
  if [ -d /proc/$pid ]; then
  #https://stackoverflow.com/questions/39066998/what-are-the-meaning-of-values-at-proc-pid-stat
    stat=$(</proc/$pid/stat)
    cmd=$(echo "$stat" | awk -F" " '{print $2}')
    state=$(echo "$stat" | awk -F" " '{print $3}')
    tty=$(echo "$stat" | awk -F" " '{print $7}')
    utime=$(echo "$stat" | awk -F" " '{print $14}')
    stime=$(echo "$stat" | awk -F" " '{print $15}')
    ttime=$((utime + stime))
    time=$((ttime / clk_tck))
    echo "${pid}|${tty}|${state}|${time}|${cmd}"
  fi
done
) | column -t -s "|"
