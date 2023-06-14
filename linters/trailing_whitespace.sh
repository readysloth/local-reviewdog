#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1")"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"
TEMPLATE="$(change_string_entry 'column' "0" "$TEMPLATE")"
TEMPLATE="$(change_string_entry 'severity' "INFO" "$TEMPLATE")"


export PYTHONPATH="$(find_lib)"
export LINTER_DIR="$(dirname "$(command -v "$0")")"

for f in $FILES
do
  "$LINTER_DIR/trailing_whitespace-lint.py" \
    --delimiter '!!!!' \
    "$LINTER_DIR/trailing_whitespace.py" \
    "$f" | sed 's/\\/\\\\/g' \
         | while read -r line
  do
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(echo "$line" | sed 's/&/\\&/g')"

    echo "$TEMPLATE" | sed -e "s@{message}@\\\n$(echo "$line" | awk -F'!!!!' '{print $3}')@" \
                           -e "s@{line}@$(echo "$line" | awk -F'!!!!' '{print $2}')@" \
                           -e "s@{file}@$f@"
  done
done
