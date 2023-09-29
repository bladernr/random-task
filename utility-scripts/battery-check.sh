#!/bin/bash

# Short script to check battery or mains status using APC tools
# for ACP UPSs

status=`apcaccess -p STATUS`

if [[ "$status" == "ONBATT" ]]; then
    echo "WARNING: RUNNING ON BATTERY POWER!"
    pct_remain=`apcaccess -p BCHARGE | awk '{print $1}'`
    echo "WARNING: Batter Percentage Remaining: $pct_remain"
else
    echo "Running on mains"
fi
