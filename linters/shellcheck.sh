#!/usr/bin/env bash


LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.sh$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"


shellcheck -e SC1090 -f gcc $FILES | while read -r line
do
  line="$(escape_quotes "$line")"
  line="$(escape_quotes "$line")"
  line="$(escape_quotes "$line")"

  REVIEWDOG_MSG="$TEMPLATE"
  REVIEWDOG_MSG="$(change_string_entry 'message' \
                                       "$(echo "$line" | awk -F': ' '{print $NF}')$append" \
                                       "$REVIEWDOG_MSG")"
  REVIEWDOG_MSG="$(change_string_entry 'line' \
                                       "$(echo "$line" | cut -d: -f2)" \
                                       "$REVIEWDOG_MSG")"
  REVIEWDOG_MSG="$(change_string_entry 'column' \
                                       "$(echo "$line" | cut -d: -f3)" \
                                       "$REVIEWDOG_MSG")"

  severity="$(echo "$line" | awk -F'[: ]' '{print $5}' | sed 's/note/info/g' | tr '[:lower:]' '[:upper:]')"
  REVIEWDOG_MSG="$(change_string_entry 'severity' \
                                       "$severity" \
                                       "$REVIEWDOG_MSG")"
  REVIEWDOG_MSG="$(change_string_entry 'file' \
                                       "$(echo "$line" | cut -d: -f1)" \
                                       "$REVIEWDOG_MSG")"
  echo "$REVIEWDOG_MSG"
done
