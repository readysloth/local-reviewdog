#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.py$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"
TEMPLATE="$(change_string_entry 'severity' "INFO" "$TEMPLATE")"


for f in $FILES
do
  pylint $f | sed -e '/^-\+/,$d' \
                  -e '/^$/d' \
                  -e '/E0401/d' \
                  -e '/C0114/d' \
                  -e '/llvm-header-guard/d' \
            | while read -r line
  do
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    append=
    if echo "$line" | grep "consider-using-from-import" &>/dev/null
    then
      append="$(create_suggestion "$(echo "$line" | cut -d"'" -f2)")"
    fi
    REVIEWDOG_MSG="$TEMPLATE"
    REVIEWDOG_MSG="$(change_string_entry 'message' \
                                         "$(echo "$line" | cut -d: -f4-)$append" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'line' \
                                         "$(echo "$line" | cut -d: -f2)" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'column' \
                                         "$(echo "$line" | cut -d: -f3)" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'file' \
                                         "$f" \
                                         "$REVIEWDOG_MSG")"
    echo "$REVIEWDOG_MSG"
  done
done
