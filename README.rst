Initial documentation notes (not tested or anything yet):

#. on your laptop::

       git clone https://github.com/trentbuck/nag ~/nag
       cd ~/nag
       systemctl --user link $PWD/nag-laptop.timer
       systemctl --user link $PWD/nag-laptop.service
       systemctl --user enable --now nag-laptop.timer
       ln -s $PWD/nag-laptop.sh ~/.local/bin/nag-laptop

#. on heavy.cyber.com.au::

       git clone https://github.com/trentbuck/nag ~/nag
       cd ~/nag
       systemctl --user link $PWD/alloc-timesheet-bullshit-hourly.service
       systemctl --user link $PWD/alloc-timesheet-bullshit-hourly.timer
       systemctl --user link $PWD/alloc-timesheet-bullshit-monthly.service
       systemctl --user link $PWD/alloc-timesheet-bullshit-monthly.timer
       systemctl --user link $PWD/nag2al.service
       systemctl --user link $PWD/nag2al.timer
       systemctl --user enable --now alloc-timesheet-bullshit-monthly.timer
       systemctl --user enable --now alloc-timesheet-bullshit-hourly.timer
       systemctl --user enable --now nag2al.timer
       ln -s $PWD/alloc-timesheet-bullshit.py ~/.local/bin/alloc-timesheet-bullshit
       ln -s $PWD/nag2al.sh                   ~/.local/bin/nag2al
       ln -s $PWD/nag2al-wrapper.sh           ~/.local/bin/nagal-wrapper
       ln -s $PWD/nag-server.sh               ~/.local/bin/nag-server
