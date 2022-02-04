#!/bin/bash
# Helper script to create a local clone of a new ubuntu kernel tree and
# pre-populate common remotes

RELEASE=$1
DEVDIR=~/development/kernels

echo "Setting up $RELEASE in $DEVDIR"
echo "..."

cd $DEVDIR/ubuntu

echo "... Cloning Ubuntu Git tree for $RELEASE"
git clone https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/$RELEASE $RELEASE

echo "... setting up remotes"
cd $DEVDIR/ubuntu/$RELEASE
git remote add mainline $DEVDIR/upstream/mainline
git remote add linux-next $DEVDIR/upstream/next
git remote add bladernr lpme:/ubuntu/+source/linux/+git/$RELEASE

echo "... review the remotes for accuracy"
git remote -v

