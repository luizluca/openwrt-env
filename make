#!/bin/bash
#
#
#
set -e

APPFILE=$(readlink -f "$(which $0)")
APPDIR=$(dirname "$APPFILE")
APPNAME=$(basename "$APPFILE")

target=${1:?First arg is target}; shift

if ! [ -e $APPDIR/.config.in.$target ]; then
	echo "Config file $APPDIR/config.in.$target does not exist!"
fi

if ! [ $APPDIR/.config.in -ot .config ] || ! [ $APPDIR/.config.in.$target -ot .config ]; then
	cat $APPDIR/config.in $APPDIR/config.in.$target >.config
	make defconfig
fi
make "$@"
