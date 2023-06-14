#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.\(c\|h\|cpp\|hpp\|cxx\|hxx\)$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"
TEMPLATE="$(change_string_entry 'column' "0" "$TEMPLATE")"


for f in $FILES
do
  flint++ $f | while read -r line
  do
    [ -z "$line" ] && continue
    echo "$line" | grep 'Lint Summary' > /dev/null && break


    line="$(echo "$line" | tr -d '[]')"
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"

    REVIEWDOG_MSG="$TEMPLATE"
    REVIEWDOG_MSG="$(change_string_entry 'message' \
                                         "$(echo "$line" | sed 's/&/\\&/g' | cut -d: -f3-)$append" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'line' \
                                         "$(echo "$line" | cut -d: -f2)" \
                                         "$REVIEWDOG_MSG")"

    severity="$(echo "$line" | cut -d' ' -f1 | sed -e 's/Advice/INFO/g' -e 's/Warning/WARNING/g' | tr '[:lower:]' '[:upper:]')"
    REVIEWDOG_MSG="$(change_string_entry 'severity' \
                                         "$severity" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'file' \
                                         "$f" \
                                         "$REVIEWDOG_MSG")"
    echo "$REVIEWDOG_MSG"
  done
done
