#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.sh$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"
TEMPLATE="$(change_string_entry 'line' "1" "$TEMPLATE")"
TEMPLATE="$(change_string_entry 'column' "0" "$TEMPLATE")"
TEMPLATE="$(change_string_entry 'severity' "INFO" "$TEMPLATE")"


TO="$(git rev-parse @)"
FROM="$TO~$1"


git log --oneline "$FROM..$TO" | while read -r gitlog_line
do echo "$gitlog_line" | gitlint 2>&1 | while read -r line
  do
      line="$(escape_quotes "$line")"
      line="$(escape_quotes "$line")"
      line="$(escape_quotes "$line")"

      REVIEWDOG_MSG="$TEMPLATE"
      REVIEWDOG_MSG="$(change_string_entry 'message' \
                                           "[$gitlog_line]: $line" \
                                           "$REVIEWDOG_MSG")"
      REVIEWDOG_MSG="$(change_string_entry 'file' \
                                           "$($GIT_CHANGED_FILES_LOC $1 | head -n1)" \
                                           "$REVIEWDOG_MSG")"
      echo "$REVIEWDOG_MSG"
  done
done
