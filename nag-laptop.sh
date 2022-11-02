#!/bin/sh
exec ssh heavy.cyber.com.au -t ~/.local/bin/nag-server "$@"
