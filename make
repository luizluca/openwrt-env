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

if [ "$(grep -v -E '^#' $APPDIR/config.out | sort -u | wc)" != "$(grep -h -v -E '^#' $APPDIR/config.out $APPDIR/config.in $APPDIR/config.in.$target | sort -u | wc)" ]; then
	echo "Regenerating config from scratch for $target..."
	diff -u <(grep -v -E '^#' $APPDIR/config.out | sort -u) <(grep -h -v -E '^#' $APPDIR/config.out $APPDIR/config.in $APPDIR/config.in.$target | sort -u) || :
	cat $APPDIR/config.in $APPDIR/config.in.$target >$APPDIR/config.out
	cat $APPDIR/config.out >$APPDIR/.config
	make defconfig
fi
make "$@"
