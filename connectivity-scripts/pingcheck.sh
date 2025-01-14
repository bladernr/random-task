#!/bin/bash
#

IP=$1

if [ -z $IP ]; then
  echo "Usage: $0 <IP>"
  exit 1
fi

ping -c 1 $IP > /dev/null

if [ $? -eq 0 ]; then
  echo "$IP is up"
else
  echo "$IP is down"
fi
