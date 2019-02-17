#!/bin/bash
#
#
#
set -e

APPFILE=$(readlink -f "$(which $0)")
APPDIR=$(dirname "$APPFILE")
APPNAME=$(basename "$APPFILE")

target=${1:?First arg is target or all}; shift

if [ "$target" = list ]; then
	for conffile in $APPDIR/config.in.*; do
		target=${conffile#*/config.in.}
		echo $target
	done
	exit
fi

if [ "$target" = "all" ]; then
	for target in $($APPFILE list); do
		$APPFILE $target "$@" || exit
	done
	exit
fi

if ! [ -e $APPDIR/config.in.$target ]; then
	echo "Config file $APPDIR/config.in.$target does not exist!" >&2
	exit 2
fi

if [ ! -e .config ]; then
	echo -n "Creating symlink "
	ln -vs $APPDIR/.config .config
fi
conf_real=$(readlink -f ".config")

if [ "$conf_real" != "$APPDIR/.config" ]; then
	echo ".config is not a symlink to '$APPDIR/.config'"
	exit 1
fi

conf_old="$(grep --no-messages --invert-match --extended-regexp '^#' $APPDIR/config.out | sort -u)" || :
conf_new="$(grep --no-filename --no-messages --invert-match --extended-regexp '^#' $APPDIR/config.out $APPDIR/config.in $APPDIR/config.in.$target | sort -u)" || :
if [ "$(wc <<<"$conf_old")" != "$(wc <<<"$conf_new")" ]; then
	echo "Regenerating config from scratch for $target..." >&2
	diff --unchanged-line-format='' --new-line-format="+%L"  <(echo "$conf_old") <(echo "$conf_new") || :
	cat $APPDIR/config.in $APPDIR/config.in.$target >$APPDIR/config.out
	cat $APPDIR/config.out >$APPDIR/.config
	echo "make defconfig" >&2
	make defconfig
	echo "make defconfig done" >&2
fi
echo "Make starting for $target at $(date)" >&2
make "$@"
echo "Make finished for $target at $(date)" >&2
