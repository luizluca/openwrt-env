#!/bin/bash
#
#
#
set -e

APPFILE=$(readlink -f "$(which $0)")
APPDIR=$(dirname "$APPFILE")
APPNAME=$(basename "$APPFILE")

target=${1:?First arg is target or all}; shift

case "$target" in
	list)
		for conffile in $APPDIR/config.in.*; do
			target=${conffile#*/config.in.}
			echo $target
		done
		exit;;
	list,)
		bash -$- $APPFILE list | xargs | tr ' ' ',';
		exit;;
	listarch)
		for target in $(bash -$- $APPFILE list); do
			bash -$- $APPFILE $target defconfig &>/dev/null || exit
			echo $target$'\t'$(sed -nre '/^CONFIG_TARGET_ARCH_PACKAGES=/{s/.*="//;s/"//;p}' $APPDIR/.config)
		done | sort -u
		exit;;
	all) 		target=$(bash -$- $APPFILE list,);;
	allarchs)	target=$(bash -$- $APPFILE listarchs | awk -F'\t' '{ T[$2]=$1 } END { for (t in T) print T[t] }' | sort | xargs | tr ' ' ',');;
esac

IFS=',' read -r -a target <<<"$target"
if [ "${#target[@]}" -gt 1 ]; then
	for target in ${target[@]}; do
		bash -$- $APPFILE $target "$@" || exit
	done
	exit
fi

if ! [ -e $APPDIR/config.in.$target ]; then
	echo "Config file $APPDIR/config.in.$target does not exist!" >&2
	exit 2
fi

if [ ! -e "key-build" ]; then
       echo "key-build is missing'" >&2
       exit 1
fi
version_id=$(md5sum key-build| cut -f1 -d' ')
#conf_real=$(readlink -f ".config")
conf_real=".config"

conf_old="$(grep --no-messages --invert-match --extended-regexp '^#' $APPDIR/config.out-$version_id | sort -u)" || :
conf_new="$(grep --no-filename --no-messages --invert-match --extended-regexp '^#' $APPDIR/config.out-$version_id $APPDIR/config.in $APPDIR/config.in.$target | sort -u)" || :
if [ "$(wc <<<"$conf_old")" != "$(wc <<<"$conf_new")" ]; then
	echo "Regenerating config from scratch for $target..." >&2
	diff --unchanged-line-format='' --new-line-format="+%L"  <(echo "$conf_old") <(echo "$conf_new") >&2 || :
	cat $APPDIR/config.in $APPDIR/config.in.$target >$APPDIR/config.out-$version_id
	cat $APPDIR/config.out-$version_id >"$conf_real"
	echo "make defconfig" >&2
	make defconfig
	echo "make defconfig done" >&2
fi
echo "Make starting for $target at $(date)" >&2
make "$@"
echo "Make finished for $target at $(date)" >&2
