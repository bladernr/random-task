#!/bin/bash
# Quick and dirty script to run the phb-crystal-ball against mainline and
# upload it to a web target.

PHBDIR=/home/bladernr/development/phb-crystal-ball/
PHB_WEB_DIR=$PHBDIR/www
PHBCOMMAND=$PHBDIR/phb-crystal-ball.py
PHB_TARGET=$1

usage () {
    echo "$0 <TARGET>"
    echo
    echo "TARGET should be a valid scp path such as:"
    echo " host:/full/path/to/target/dir"
    echo 
}

#verify we have a target
if [ "$#" -ne 1 ]; then
        echo "ERROR: No target specified"
        usage
        exit 1
fi

#clean the www staging area up
rm -f $PHB_WEB_DIR/*

#consult the oracles
$PHBCOMMAND

#upload to the target
scp $PHB_WEB_DIR/* $PHB_TARGET &&
    echo "Upload to $PHB_TARGET SUCCESS" ||
    echo "Upload to $PHB_TARGET FAILED!"

