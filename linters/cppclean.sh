#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.\(c\|h\|cpp\|hpp\|cxx\|hxx\)$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"
TEMPLATE="$(change_string_entry 'column' "0" "$TEMPLATE")"
TEMPLATE="$(change_string_entry 'severity' "INFO" "$TEMPLATE")"


INCLUDES=" "

for f in $FILES
do
  cppclean $INCLUDES $f 2>/dev/null | sed -e 's/::/!!/g' \
                                    | while read -r line
  do
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(echo "$line" | awk -F: '{if(NF==2){printf "%s:0:%s", $1, $2}else{printf "%s:%s:%s", $1, $2, $3}}')"

    REVIEWDOG_MSG="$TEMPLATE"
    REVIEWDOG_MSG="$(change_string_entry 'message' \
                                         "$(echo "$line" | sed 's/&/\\&/g' | cut -d: -f3- | sed 's/!!/::/g')$append" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'line' \
                                         "$(echo "$line" | cut -d: -f2)" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'file' \
                                         "$(echo "$line" | cut -d: -f1)" \
                                         "$REVIEWDOG_MSG")"
    echo "$REVIEWDOG_MSG"
  done
done
