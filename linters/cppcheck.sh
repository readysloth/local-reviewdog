#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.\(c\|h\|cpp\|hpp\|cxx\|hxx\)$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"

cppcheck \
  --enable=all \
  --addon=misc \
  --addon=findcasts \
  --std=c++11 \
  --platform=unix64 \
  --output-file=cppcheck.log \
  --language=c++ \
  --template="$TEMPLATE" \
  $FILES &>/dev/null

for f in $FILES
do
  grep "$f" cppcheck.log | sed -e 's/"severity": "style"/"severity": "INFO"/' \
                               -e 's/"severity": "information"/"severity": "INFO"/' \
                               -e 's/"severity": "performance"/"severity": "INFO"/' \
                               -e 's/"severity": "warning"/"severity": "WARNING"/' \
                               -e 's/"severity": "error"/"severity": "ERROR"/'
done
