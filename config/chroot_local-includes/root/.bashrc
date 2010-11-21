#!/bin/sh -e

if [ "$PS1" ]; then
dpkg-reconfigure keyboard-configuration
setupcon
sh ../dialog.sh
fi
