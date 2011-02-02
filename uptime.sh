#!/bin/bash
# Requires non-interactive SSH auth between CCIS machines, such as that provided by auto-ssh.sh
# Suggested usage: ./uptime.sh | sort -rg | head -n 20

FILT_UPTIME_1="sed 's:.*[^0-9]\([0-9]\+\) day.*:\1:'"
FILT_UPTIME_2="sed 's|.*[^0-9]\([0-9]\+\):[0-9]\+:[0-9]\+ up.*|\1|'"

for x in `/ccis/bin/linuxmachines 2>&1 | grep -v virtual | grep -v account. | grep ccs.neu.edu | sed 's/^\([a-z0-9]\+\).*/\1/'`
do
   days=`ssh -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=false $x "uptime | $FILT_UPTIME_1 | $FILT_UPTIME_2" 2>/dev/null`
   SSH_EXIT="$?"
   if [ "$SSH_EXIT" -eq "0" ] ; then
     echo "$days $x"
   fi
done

