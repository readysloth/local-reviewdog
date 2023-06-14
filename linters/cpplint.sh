#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.\(c\|h\|cpp\|hpp\|cxx\|hxx\)$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"
TEMPLATE="$(change_string_entry 'column' "0" "$TEMPLATE")"
TEMPLATE="$(change_string_entry 'severity' "INFO" "$TEMPLATE")"


EXCLUDED_CHECKS="$(eval echo -whitespace/{braces,indent,comments,parens} | tr ' ' ,),-legal/copyright,-build/include_order,-build/c++11"

cpplint --linelength=128 \
        --filter=$EXCLUDED_CHECKS $FILES 2>&1 | \
        sed -e '/Done processing/d' \
            -e '/Skipping input/d' | while read -r line
do
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    append=
    if echo "$line" | grep "Redundant blank line" &>/dev/null
    then
      append="$(create_suggestion "")"
    fi

    REVIEWDOG_MSG="$TEMPLATE"
    REVIEWDOG_MSG="$(change_string_entry 'message' \
                                         "$(echo "$line" | sed 's/&/\\&/g' | cut -d: -f3-)$append" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'line' \
                                         "$(echo "$line" | cut -d: -f2)" \
                                         "$REVIEWDOG_MSG")"
    REVIEWDOG_MSG="$(change_string_entry 'file' \
                                         "$(echo "$line" | cut -d: -f1)" \
                                         "$REVIEWDOG_MSG")"
    echo "$REVIEWDOG_MSG"
done
