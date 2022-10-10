#!/bin/bash -eEu
PATH="$PATH:$HOME/.local/bin"   # YUK.
trap 'echo >&2 "$0: unknown error"' ERR

day1= time1= task1= comment1=
while read day time task comment
do
    [[ $task =~ ^[[:digit:]]+$ ]] ||
    comment="$task${comment:+ $comment}" task=?????

    # Truncate to the zeroth second.  This prevents the period
    # 10:00:00 to 10:15:01 being rounded up to a half-hour.
    time="${time%:??[+-]??:??}:00${time#??:??:??}"

    # Unless the task/comment has changed, this isn't a "real" edge,
    # so proceed on to the next one (without setting the foo1 old
    # flavours).
    test "$task1$comment1" != "$task$comment" || continue

    if test -n "$day1"         # we've seen at least one entry before.
    then
        dur=$((($(date -d"$day $time" +%s) - $(date -d"$day1 $time1" +%s))))
        dur=$(((dur/900) + !!(dur%900)))                  # round to nearest 15min
#       [[ $comment1 =~ ^(email|food|home|fnord.*)$ ]] || # skip boring entries
#       [[ $task1 = '?????' && $comment1 =~ ^(home|fnord.*)$ ]] || # skip boring entries
        {
            echo alloc work -qt"$task1" -d"$day1" -h"$((dur*15))m" -c"${comment1:-NO COMMENT} [${time1%?????????}]"
            alloc work -qt"$task1" -d"$day1" -h"$((dur*15))m" -c"${comment1:-NO COMMENT} [${time1%?????????}]" || echo FAILED
        }
    fi
    day1=$day time1=$time task1=$task comment1=$comment
done < <(cat "$@" | sort)
