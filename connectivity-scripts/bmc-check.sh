#!/bin/bash
#

TARGET=$1
PASS="1Nsecure!"
USER="ubuntu"

if [ -z $TARGET ]; then
  echo "Usage: $0 <target>"
  exit 1
fi

ipmitool -I lanplus -H $TARGET -U $USER -P $PASS chassis status

if [ $? -ne 0 ]; then
  echo "Failed to connect to $TARGET"
  exit 1
fi
