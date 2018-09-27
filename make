#!/bin/bash
#
#
#
set -e
target=$1; shift
if ! git rev-parse --verify --quiet $target>/dev/null; then
	
fi

if [ "$target" != "$(cd env; git rev-parse --abbrev-ref HEAD)" ]; then
	./scripts/env switch $target
fi
make "$@"
