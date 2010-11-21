#!/bin/sh -e
dpkg-reconfigure keyboard-configuration
setupcon
sh ../dialog.sh
