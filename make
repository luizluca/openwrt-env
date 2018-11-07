#!/bin/bash
#
#
#
set -e

APPFILE=$(readlink -f "$(which $0)")
APPDIR=$(dirname "$APPFILE")
APPNAME=$(basename "$APPFILE")

target=${1:?First arg is target}; shift

if ! [ -e $APPDIR/config.in.$target ]; then
	echo "Config file $APPDIR/config.in.$target does not exist!"
	exit
fi

if [ "$(cat .config | sort -u | wc)" != "$(cat .config $APPDIR/config.in $APPDIR/config.in.$target | sort -u | wc)" ]; then
	echo "Regenerating config from scratch for $target..."
	cat $APPDIR/config.in $APPDIR/config.in.$target >.config
	make defconfig
fi
make "$@"
