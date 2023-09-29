 #!/bin/bash
 
 #This script syncs a remote computer to this one

 cd /home/bladernr

 # Uncomment the next command if you'd like to copy all of
 # the files (not directories) in your home dir to the remote machine.

 # cp * ./sync/

 rsync -arLuvz /home/bladernr/.sync/ $1:/home/bladernr
