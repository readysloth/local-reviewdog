#!/usr/bin/env bash
# TODO: Протестировать


GIT_CHANGED_FILES=git-changed-files.sh

TRY_PATH="$(dirname "$0")/utils/$GIT_CHANGED_FILES"
[ -z "$GIT_CHANGED_FILES_LOC" ] && [ -f "$TRY_PATH" ] && GIT_CHANGED_FILES_LOC="$TRY_PATH"
TRY_PATH="$(dirname "$0")/../utils/$GIT_CHANGED_FILES"
[ -z "$GIT_CHANGED_FILES_LOC" ] && [ -f "$TRY_PATH" ] && GIT_CHANGED_FILES_LOC="$TRY_PATH"
[ -z "$GIT_CHANGED_FILES_LOC" ] && GIT_CHANGED_FILES_LOC="$(command -v git-changed-files.sh)"
[ -z "$GIT_CHANGED_FILES_LOC" ] && echo "Didn't find $GIT_CHANGED_FILES script" && exit 1


FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.py$')"

TEMPLATE_RANGE='"range": {"start": {"line": 0, "column": 0}}'
TEMPLATE_LOC="\"location\": {\"path\" : \"{file}\", $TEMPLATE_RANGE}"
TEMPLATE="{\"message\": \"*$(basename "$0"):* {message}\", $TEMPLATE_LOC, \"severity\": \"INFO\"}"


for f in $FILES
do
  heading="$(isort -c "$f" 2>&1)"
  [ $? == 0 ] && continue

  diff="$(isort --diff "$f" | sed '1,2d' | tr '\n' '~' | sed 's/~/\\\\n/g')"
  message="$heading:\\\\n\`\`\`diff\\\\n$diff\\\\n\`\`\`"
  message="$(echo "$message" | sed 's!"!\\\\"!g')"
  echo "$TEMPLATE" | sed -e "s!{message}!$(echo "$message" | sed 's/&/\\&/g')!" \
                         -e "s@{file}@$f@"
done
