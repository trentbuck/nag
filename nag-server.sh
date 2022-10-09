#!/bin/bash
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
##
## In your crontab, try:
##     PATH=/home/twb/.bin:/usr/local/bin:/usr/bin:/bin
##     */15 *  * * *  INSIDE_CRON=true nag

set -eEu
set -o pipefail
trap 'echo >&2 "${0##*/}:${LINENO}: unknown error"' ERR

# This is flora, where the file is read/written.
while getopts wd: opt
do  case "$opt" in
        # Force me to stop and think.
        # FIXME: doesn't discard stuff I type while doing this.
        w) wait=true;;
        # Let's me backdate entries easily.
        d) date=$OPTARG;;
    esac
done
shift $((${OPTIND:-1}-1))

now="$(date -d"${date-now}" --rfc-3339 seconds)"

if test 0 -eq $#
then
    toilet -tffuture "What are you doing?!" || test 127 = $?
    if test -f ~/.timelog
    then
        tail ~/.timelog     # print the last few entries.

        # Store a single copy of all unique entries in history file.
        HISTFILE=$(mktemp -t nag.XXXXXX)
        cut -c27- ~/.timelog | uniq | tail -128 >"$HISTFILE"
        history -c                      # Clear all current history.
        history -n                      # Read everything from history file.
        old=$(tail -1 "$HISTFILE")
        rm -f "$HISTFILE"
    fi
    test -z "${wait-}" || sleep 2
    read -ep $'\1'"$(tput setaf 2||:)"$'\2'"$now"$'\1'"$(tput sgr0||:)"$'\2'" " -i "${old-}" response
    set -- "$response"
fi

echo "$now $*" >>~/.timelog

# 18:28 <twb> The problem I have is that (I think) read is assuming all the prompt characters are printable, so if I press <up> and <down>, the completion is too far to the left and the line gets scrambled.
# 18:29 <twb> I tried adding \[ and \], like one does for PS1, but they just got printed.
# 18:33 <pgas> twb: use $'\1' $'\2' instead of \[ \]
# 18:33 <twb> Where is that documented?
# 18:34 <pgas> it's not
# 18:34 <twb> Not even in rluserman or something? :-)
# 18:34 <pgas> ah well, maybe I don't know
# 18:35 <pgas> Chet has gave this answer to the bug-bash list, so you can rely on it ;)
# 18:35 <pgas> has given
# 18:53 <Riviera> twb: RL_PROMPT_START_IGNORE and RL_PROMPT_END_IGNORE in readline.h
