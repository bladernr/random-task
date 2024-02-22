#!/bin/bash

STARTID=$1
GIT_BRANCH=$(git branch --show-current)
GIT_REMOTE=$(git remote -v |grep -m 1 bladernr|awk -F@ '{print $2}'|cut -d' ' -f1)

echo "creating PR message for $GIT_BRANCH starting from $STARTID"

git request-pull $STARTID "https://"$GIT_REMOTE $GIT_BRANCH |tee -a $GIT_BRANCH.message
