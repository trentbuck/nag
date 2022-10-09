Initial documentation notes (not tested or anything yet):

#. on your laptop::

       git clone https://github.com/trentbuck/nag ~/nag
       cd ~/nag
       systemctl --user link nag-laptop.timer
       systemctl --user link nag-laptop.service
       systemctl --user enable --now nag-laptop.timer
       ln -s $PWD/nag-laptop.sh ~/.local/bin/nag-laptop

#. on heavy.cyber.com.au::

       git clone https://github.com/trentbuck/nag ~/nag
       cd ~/nag
       systemctl --user link alloc-timesheet-bullshit-hourly.service
       systemctl --user link alloc-timesheet-bullshit-hourly.timer
       systemctl --user link alloc-timesheet-bullshit-monthly.service
       systemctl --user link alloc-timesheet-bullshit-monthly.timer
       ln -s $PWD/alloc-timesheet-bullshit.py ~/.local/bin/alloc-timesheet-bullshit
       ln -s $PWD/nag2al.sh                   ~/.local/bin/nag2al
       ln -s $PWD/nag-server.sh               ~/.local/bin/nag-server
