#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1")"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"
TEMPLATE="$(change_string_entry 'line' "0" "$TEMPLATE")"
TEMPLATE="$(change_string_entry 'column' "0" "$TEMPLATE")"
TEMPLATE="$(change_string_entry 'severity' "ERROR" "$TEMPLATE")"


export PYTHONPATH="$(find_lib)"
export LINTER_DIR="$(dirname "$(command -v "$0")")"

for f in $FILES
do
  if ! bash -c "cat \"$f\" | iconv -f UTF-8 -t UTF-8 > /dev/null 2>/dev/null"
  then
    echo "$TEMPLATE" | sed -e "s@{message}@Файл не в кодировке UTF-8@" \
                           -e "s@{file}@$f@"
  fi
done
