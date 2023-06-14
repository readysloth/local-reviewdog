#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.py$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"
TEMPLATE="$(change_string_entry 'column' '0' "$TEMPLATE")"
TEMPLATE="$(change_string_entry 'severity' 'INFO' "$TEMPLATE")"

for f in $FILES
do
  pytype -d import-error $f | grep '^File' |while read -r line
  do
    echo "$line" | grep "$f" &>/dev/null || continue
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"

    REVIEWDOG_MSG="$TEMPLATE"
    REVIEWDOG_MSG="$(change_string_entry 'message' \
                                         "$(echo "$line" | sed 's/^.*line [[:digit:]]\+, \(.*\)$/\1/' )" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'line' \
                                         "$(echo "$line" | sed 's/^.*line \([[:digit:]]\+\).*$/\1/' )" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'file' \
                                         "$f" \
                                         "$REVIEWDOG_MSG")"
    echo "$REVIEWDOG_MSG"
  done
done
