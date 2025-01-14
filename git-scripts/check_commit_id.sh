#!/usr/bin/bash
#set -x
# add check for patches already in kernel

filename="$1"
status_file="../latest.txt"
# commit_id=`cut -f 1 -d " " $filename | tac`
commit_id=(`cat $filename |awk '{print $1}'`)



#cmd1="git --no-pager log --remotes=staging --oneline | grep "
#cmd1="git --no-pager log --remotes=staging  | grep "

#cmd1="git --no-pager log --remotes=linux-next --oneline | grep "
#cmd1="git --no-pager log --remotes=linux-next  | grep "

#cmd1="git --no-pager log --remotes=linus --oneline | grep "
#cmd1="git --no-pager log --remotes=linus | grep "

#cmd1="git --no-pager log --remotes=mainline --oneline | grep "
cmd1="git --no-pager log --remotes=mainline | grep "

cmd3="git cherry-pick -e -s -x "
#cmd5="git --no-pager log --oneline | grep -m 1 "
cmd5="git --no-pager log  | grep -m 1 "

reset_id=`git log | grep commit -m 1 | cut -d" " -f 2`
cmd_reset="git reset --hard $reset_id"
git_dir="/home/bladernr/development/kernels-ubuntu/jammy/"
patch_count=0

pushd $git_dir
pwd

for i in "${commit_id[@]}"
  do
    cmd7=$cmd5$i
    echo $cmd7

    eval $cmd7
    result=$?

    if [ $result -eq 0 ]; then
        echo "Patch  $i is already present"
        patch_count=$(expr $patch_count + 1)
    else
      cmd2=$cmd1$i" -m 1"
      echo $cmd2

      eval $cmd2
      result=$?

      if [ $result -eq 0 ]; then
        echo "$i found"
        cmd4=$cmd3$i

        eval $cmd4
        if [ $? -eq 0 ]; then
          echo "$i picked cleanly"
          patch_count=$(expr $patch_count + 1)
          echo "patch count = $patch_count"
        else
          echo "$i did not pick cleanly"
          patch_count=$(expr $patch_count + 1)
          popd
          > $status_file
          for((num=patch_count; num<${#commit_id[@]};num++))
            do
              echo "${commit_id[$num]}" | tee -a $status_file
            done
          exit 0
        fi
      else
        echo "$i not found in remotes"
        exit 0
      fi
    fi
  done

popd
echo "All patches applied cleanly"
