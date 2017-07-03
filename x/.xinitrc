#!/bin/bash

# In case everything goes wrong, we at least fall back to a plain xterm
failsafe="xterm -ls -T Failsafe -geometry 80x24-0-0"
trap "exec $failsafe" EXIT SIGHUP SIGINT SIGPIPE SIGTERM SIGIO

# Some bash (1 and 2) settings to avoid trouble on a
# failed program call.
set +e > /dev/null 2>&1
set +u > /dev/null 2>&1
set +o posix  > /dev/null 2>&1
if type shopt > /dev/null 2>&1 ; then
    shopt -s execfail
else
    no_exit_on_failed_exec=1
fi

# Source common code shared between the
# X session and X init scripts
if [ -f "/etc/X11/xinit/xinitrc.common" ]; then
    . /etc/X11/xinit/xinitrc.common
fi

# Special for twm
case "$WINDOWMANAGER" in
    *twm) xsetroot -solid darkslateblue
esac

# Source .Xresources if it exists
if [ -e "$HOME/.Xresources" ]; then
    xrdb "$HOME/.Xresources"
fi

# Start rxvt daemon for improvements to speed and memory usage
urxvtd --quiet --opendisplay --fork

# finally start the window manager
unset WINDOW_MANAGER STARTUP
exec $WINDOWMANAGER ${1+"$@"}

# call failsafe
exit 0
