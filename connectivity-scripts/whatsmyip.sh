#!/bin/bash
# validate my current public IP and update ip.html if it's changed.
# WHATS_MY_IP_POST_URL is an env var that points to a webserver target where
# you want to scp the resulting ip text file.

#url=http://whatismyip.org
url=http://icanhazip.com
ipfile=~/.external_ip_address

CheckFile () {
    echo "checking for file"
    if [ -f $ipfile ]; then
        old=`head $ipfile | awk '{print $2}'`
        echo "file exists, going to check ip"
        CheckIP
    else
        echo "file does not exist. creating"
        touch $ipfile
        CheckFile
    fi
}

CheckIP () {
    echo "checking ip"
    check=`curl -s $url`
    echo "ip checked, now validating"
    Validate
}

Validate () {
    echo "validating address"
    if [ "$check" = "" ]; then
        echo "Address returned blank, waiting 1 minutes and checking again" 
        sleep 60
        CheckIP
    else 
        echo "address valid, updating ip"
        new=$check
        UpdateIP
    fi
}

UpdateIP () {
    if [ "$new" != "$old" ]; then
	ts=`date +%Y-%m-%d_%H:%M`
        echo "writing ip to $ipfile"
        echo "$ts $new" > $ipfile
        scp $ipfile $WHATS_MY_IP_POST_URL
    else
        echo "ip has not changed"
    fi
}

CheckFile
