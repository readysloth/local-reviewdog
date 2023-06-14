#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.\(c\|h\|cpp\|hpp\|cxx\|hxx\)$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"


COMPILER_ARGS=""


for f in $FILES
do
  clang-tidy -checks=* \
             $(for a in $COMPILER_ARGS; do echo "--extra-arg=$a"; done) \
             $f 2>/dev/null | grep '^/' \
                            | sed -e 's/::/!!/g' \
                            | while read -r line
  do
    echo "$line" | grep "$f" &>/dev/null || continue
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"

    REVIEWDOG_MSG="$TEMPLATE"
    REVIEWDOG_MSG="$(change_string_entry 'message' \
                                         "$(echo "$line" | sed 's/&/\\&/g' | cut -d: -f5- | sed 's/!!/::/g')$append" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'line' \
                                         "$(echo "$line" | cut -d: -f2)" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'column' \
                                         "$(echo "$line" | cut -d: -f3)" \
                                         "$REVIEWDOG_MSG")"

    severity="$(echo "$line" | cut -d: -f4 | tr -d ' ' | tr '[:lower:]' '[:upper:]')"
    REVIEWDOG_MSG="$(change_string_entry 'severity' \
                                         "$severity" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'file' \
                                         "$f" \
                                         "$REVIEWDOG_MSG")"
    echo "$REVIEWDOG_MSG"
  done
done
