#!/bin/sh -e

if [ -z "$MR_BRANCH" ]
then
  TO="$(git rev-parse @)"
  FROM="$TO~$1"
  git diff-tree --no-commit-id --name-only -r "$FROM..$TO"
else
  git diff-tree --no-commit-id --name-only -r FETCH_HEAD
fi
