#!/bin/bash

# FIXME: this entire script is bullshit.
#        rewrite nag2al in python, and fold these hacks into that.

PATH="$PATH:$HOME/.local/bin"   # YUK.

{

    # Get all events with yesterday's timestamp.
    if ! grep "^$(date -I -dyesterday)" ~/.timelog
    then echo "There were no nag logs yesterday" >&2
    fi |

    # Add a fake timestamp to the bottom.
    # This might make nag2al create a timestamp entry if I forget to clock out?
    # I do not remember exactly why this is here, and the old cron job didn't say.
    awk '{print}END{print $1, $2, "23321 dummy time event to hopefully cause the previous real event to actually get logged into alloc"}' |

    # Do the nag2al stuff.
    nag2al

} |&

# Instead of putting stuff into "journalctl --user",
# which ends up in logcheck@ emails,
# send me an email instead.
# FIXME: This is deeply shitty.
mail -s "nag2al output" "$USER"
