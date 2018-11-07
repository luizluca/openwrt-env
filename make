#!/bin/bash
#
#
#
set -e

APPFILE=$(readlink -f "$(which $0)")
APPDIR=$(dirname "$APPFILE")
APPNAME=$(basename "$APPFILE")

target=${1:?First arg is branch-target}; shift
if [ "$target" != "$(cd env; git rev-parse --abbrev-ref HEAD)" ]; then
	./scripts/env switch $target
fi

if ! [ $APPDIR/.config.in -ot .config ]; then
	cat $APPDIR/.config.in >.config
	make defconfig
fi
make "$@"
