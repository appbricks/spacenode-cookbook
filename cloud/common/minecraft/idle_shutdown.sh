#!/bin/bash

set -e

num_connected_clients=$(mcstatus localhost status | awk '/players:/{ split($2,n,"/"); print n[1] }')

shutdown_counter=${mc_root}/logs/shutdown_countdown
counter=$([[ -e $shutdown_counter ]] && cat $shutdown_counter || echo 10)
if [[ $num_connected_clients -eq 0 ]]; then
  counter=$((counter-1))
else
  counter=10
fi
if [[ $counter -gt 0 ]]; then
  echo "$counter" > $shutdown_counter
else
  rm $shutdown_counter
  echo $(date +"%Y-%m-%d %H:%M:%S")' Shutting down instance due to inactivity...' >> ${mc_root}/logs/shutdown.log
  sudo shutdown now
fi
