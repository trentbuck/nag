#!/bin/bash
set -eEu -o pipefail
shopt -s failglob
trap 'echo >&2 "$0:${LINENO}: unknown error"' ERR

## UPDATE: I don't understand why,
## but when LANG is not set,
## the actual task list never appears.
## (It still emits the "For fuck's sake" lines.)
export LANG=en_AU.UTF-8

# Usage examples:
#
#    tasks-over-limit
#    tasks-over-limit -- '2 weeks'
#    tasks-over-limit -a mike -- '1 month'
#
# NB: the last WILL NOT WORK unless you are manager.
#
# UPDATE: it won't work for ANYONE, because
#
#    WORKS: alloc timesheets '-d>=2015-10-15' -atwb
#    FAILS: alloc timesheets '-d>=2015-10-15' -atwb -isall
#
# FIXME: bitch about this to alla.

while getopts a: opt
do  case "$opt" in
        a) who=$OPTARG;;
        '?') exit 1;;
    esac
done
shift $((${OPTIND:-1}-1))

since="${*:-1 week}"

# This generates a list like xs=(-t1234 -t1235).
# It splits on whitespace, because I'm a lazy fucking asshole.
args=($(alloc timesheets ${who:+ -a "$who"} -isall -d">=$(date -I -d "-$since")" -'fTask ID' -fWarning |
        sed -n /Exceeds.Limit/p | cut -d, -f1 | sort -u | sed s/^/-t/))

((${#args[@]})) || exit 0       # if nothing is over limit, we're done

cat <<EOF
For fuck's sake, ${who:-you fucking idiot}.

You recently (since $since) worked on these tasks,
and they're currently over their limit.

EOF


# Normal args that I put in to get the fields I actually care about.
# FIXME: add in "how much is this over the limit? (percentage, and absolute)"
args+=(
    -o'Pri Factor'
    -otimeExpectedLabel
    -otaskID

    ##-fparentTaskID
    -ftaskID
    -fassignee_username
    -fprojectShortName
    -fStat
    ##-f'Pri Factor'
    ##-ftimeExpectedLabel

    ## FIXME: file a bug against alla for this:
    # 18:13 <twb> FAILS: "alloc tasks -fAct"
    # 18:13 <twb> WORKS: "alloc tasks -fAct -ftimeLimit"
    # 18:13 <twb> The second option somehow magically makes the first option work
    # 18:13 <twb> This is fucking bullshit
    -fAct                       # hours spent (by everone)
    -ftimeLimit


    -fTask
    -fTags

    --csv)

{
    # Add my own (shorter, less insane) field titles.
    echo 'Task,Ass,Proj,St,Spent,Limit,Subject,[Tags]'

    alloc tasks "${args[@]}"
} |

######################################################################
### Now fix all the fucking formatting.
######################################################################

# strip alla's field labels (there is no opt-out CLI option).
# They make columns too wide.
sed 2d |

# Merge the "tag" and "subject" fields,
# because both are arbitrary width.
# cjb says he can't fix this in alloc-cli.
sed -r 's/(.*),/\1 /;s/ $//' |

# Fix alla's STUPID task statuses.
sed 's/pending_manager/PM/;s/pending_tasks/PT/;s/pending_client/PC/;s/pending_info/PI/' |
sed 's/open_inprogress/O/;s/open_notstarted/O/' |
sed 's/closed_complete/C/;s/closed_invalid/Wf/;s/closed_duplicate/D/' |
# Fix alla's STUPID numbers
sed 's/ hrs,/,/g; s/\.00,/,/g;s/99999\.99/INF/g;' |
sed 's/\.25,/¼,/g; s/\.50\?,/½,/g; s/\.75,/¾,/g;' |
sed 's/,0\(¼\|½\|¾\),/,\1,/g' |

# Line up all the columns nicely.
column -nts,
