#!/usr/bin/python3
import os
import argparse
import datetime
import subprocess
import textwrap


def get_timesheet_ids(*constraint_args):
    proc = subprocess.run(
        ['alloc', 'timesheets',
         # Only bother to request the field we actually want.
         # UPDATE: actually don't; it triggers bugs in "alloc submit":
         #   printf '123\n456' | alloc submit ---> submits "45" not "456".
         #   printf '\n'       | alloc submit ---> submits "" not nothing.
         #   printf '123,a\n456,b' | alloc submit --> correct behaviour
         # '--fields', 'ID',
         # "alloc submit" gets bitchy if we try to submit timesheets
         # in any other state.
         '--status', 'edit',
         # "alloc submit" gets bitchy if we try to submit timesheets
         # with no time on them.
         '--hours', '>0',
         *constraint_args],
        text=True,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)  # for --systemd-timer
    timesheet_ids = proc.stdout.splitlines()
    # "alloc submit" gets bitchy if we do not manually remove the header field.
    timesheet_ids = timesheet_ids[1:]
    return set(timesheet_ids)


parser = argparse.ArgumentParser(
    epilog="""
    In theory, I *never* need to look at timeSHEETS at all.
    I just make sure my timesheet ITEMS are in alloc, and I am done.
    In practice, this "timesheet submission" shit has to happen SOMEWHERE.
    This has been fully automated for me since 2016 (or earlier).
    This script implements that automation.
    I tweaked the logic until managers and alloc both stopped whinging.
    """)
parser.add_argument(
    '--systemd-timer', action='store_true',
    help='if something goes wrong, send an email')
parser.add_argument(
    '--all-timesheets', action='store_true')
args = parser.parse_args()

try:
    if args.all_timesheets:
        # Originally I was told "a given timeSHEET must not contain
        # timesheet ITEMS from more than one financial year".
        # So I just did "alloc timesheets | alloc submit" at midnight
        # on 1 June.
        #
        # That needed some tweaking to avoid "alloc submit" just
        # crashing on that input.
        # That tweaking is now built into get_timesheet_ids, above.
        # Then I was told "some customers with contracts might change
        # contracts on calendar months", so do that monthly.
        timesheet_ids = get_timesheet_ids()
    else:
        # Managers also complain if timesheets
        #   1. have "too much time" on them, or
        #   2. "are too old".
        # Therefore submit anything that is large and/or old.
        last_week = (
            datetime.date.today() - datetime.timedelta(days=7))
        timesheet_ids = (
            get_timesheet_ids('--hours', '>=7') |
            get_timesheet_ids('--date', f'<={last_week}'))
    subprocess.run(
        ['alloc', 'submit'],
        check=True,
        text=True,
        stdout=subprocess.PIPE,  # for --systemd-timer
        stderr=subprocess.PIPE,  # for --systemd-timer
        input='\n'.join(timesheet_ids))
except subprocess.CalledProcessError as e:
    body = (
        f'{e}\n'       # includes includes the command & the exit code
        f'STDOUT:\n{textwrap.indent(e.stdout.strip(), "    ")}\n'
        f'STDERR:\n{textwrap.indent(e.stderr.strip(), "    ")}\n')
    if args.systemd_timer:
        subprocess.run(
            ['mail',
             '-s', 'alloc-timesheet-bullshit Failed',
             os.getlogin()],
            text=True,
            check=True,
            input=body)
    else:
        print(body, end='')
        exit(os.EX_OSERR)
