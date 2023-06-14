#!/usr/bin/env bash

set -e

COMMIT_OFFSET="$1"
LINTER="$2"

[ -z "$COMMIT_OFFSET" ] && echo 'You must specify commit offset from HEAD' && exit 1
[ -z "$LINTER" ] && echo 'You must specify linter from linters/' && exit 1
REVIEWDOG="$(dirname "$(command -v "$0")")/reviewdog.sh"


"$LINTER" $COMMIT_OFFSET | while read -r line
do
   while [ "$(jobs -p | wc -l)" -gt "$(nproc)" ]; do sleep 1; done
   echo "$line" | "$REVIEWDOG" $COMMIT_OFFSET &
done

wait $(jobs -p)
