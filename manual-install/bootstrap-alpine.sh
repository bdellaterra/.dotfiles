#!/bin/sh

sudo apk add bash
sudo apk add tzdata

# From Clandmeter, 2013, "https://wiki.alpinelinux.org/wiki/Setting_the_timezone"
echo
echo "NOTE: Set local timezone with a commands similar to the example below. (Use your own location)"
echo "sudo cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime"
