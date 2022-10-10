#!/bin/bash

# FIXME: this entire script is bullshit.
#        rewrite nag2al in python, and fold these hacks into that.

PATH="$PATH:$HOME/.local/bin"   # YUK.

# Get all events with yesterday's timestamp.
grep "^$(date -I -dyesterday)" ~/.timelog |

# Add a fake timestamp to the bottom.
# This might make nag2al create a timestamp entry if I forget to clock out?
# I do not remember exactly why this is here, and the old cron job didn't say.
awk '{print}END{print $1, $2, "fnord"}' |

# Do the nag2al stuff.
chronic nag2al |

# Instead of putting stuff into "journalctl --user",
# which ends up in logcheck@ emails,
# send me an email instead.
# FIXME: This is deeply shitty.
mail -s "nag2al output" "$USER"
