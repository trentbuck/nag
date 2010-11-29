#!/bin/bash -ueE
## Problem: I forget to file timesheets, and I'm easily distracted
## such that I forget WHEN I changed from working on ticket N to
## working on ticket M.
##
## Therefore, run this from a crontab every fifteen minutes.  It will
## pop up an editor in my screen session, prompting me to write down
## what I'm doing RIGHT NOW.
##
## Do nothing if the previous popup is still open, so that after being
## AFK I don't return to a session with hundreds of popups.
##
## FIXME: use sqlite or tokyocabinet so backdated timestamps will be
## sorted correctly.

while getopts "hpd:" opt
do  case "$opt" in
        d)  date=$OPTARG;;
        p)                      # cron is trying to popup a window.
            test -n "$(find /dev/tty?* /dev/pts -user "$EUID" -mmin -14 -print -quit)"
            getent hosts flora.cyber.com.au >/dev/null
            exec screen -X screen -t nag ssh flora.cyber.com.au -t ~/.bin/nag
            ;;
        h|'?')
            echo "Usage: nag [ -p | [-dDATE] [MESSAGE] ]"
            echo "In your crontab, try:"
            echo "    PATH=/home/twb/.bin:/usr/local/bin:/usr/bin:/bin"
            echo "    */15 *  * * *  nag -p"
            exit 1;;
    esac
done
shift $((${OPTIND:-1}-1))

now="$(date -d"${date-now}" --rfc-3339 seconds)"

if test 0 -eq $#
then
    toilet -tffuture "What are you doing?!" || test 127 = $?
    if test -f ~/.timelog
    then
        tail ~/.timelog
        old=$(sed -rn '$ s/^.{26}//p' ~/.timelog)

        # Allocate new history file and delete it on exit.
        HISTFILE=$(mktemp -t nag.XXXXXX)
        trap "rm -f \"$HISTFILE\"" 0 TERM ERR QUIT

        # Store a single copy of all unique entries in history file.
        sed -rn 's/^.{26}//p' ~/.timelog | uniq > $HISTFILE
        history -c                      # Clear all current history.
        history -n                      # Read everything from history file.
    fi
    read -ep "$now " -i "${old-}" response
    set -- "$response"
fi

echo "$now $*" >>~/.timelog
