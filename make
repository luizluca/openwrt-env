#!/bin/bash
#
#
#
set -e
target=$1; shift
if [ "$target" != "$(cd env; git rev-parse --abbrev-ref HEAD)" ]; then
	./scripts/env switch $target
fi
make "$@"
