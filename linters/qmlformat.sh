#!/usr/bin/env bash

LINTER="$(basename "$0")"

. "$(dirname "$(command -v "$0")")/reviewdog-linters-common.sh"

GIT_CHANGED_FILES_LOC="$(find_git_changed_files)"
FILES="$($GIT_CHANGED_FILES_LOC "$1" | grep '\.qml$')"
TEMPLATE="$(change_string_entry 'script' "$LINTER" "$(get_raw_template)")"
TEMPLATE="$(change_string_entry 'column' "0" "$TEMPLATE")"
TEMPLATE="$(change_string_entry 'severity' "INFO" "$TEMPLATE")"


export PYTHONPATH="$(find_lib)"

for f in $FILES
do
  qmlformat.py --delimiter '!!!!' $f | sed 's/\\/\\\\/g'\
                                     | while read -r line
  do
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"
    line="$(escape_quotes "$line")"

    codestyle_url="[QML Coding Conventions](http://172.16.7.1:8000/QT/doc.qt.io/qt-5.15/qml-codingconventions.html)"
    echo "$TEMPLATE" | sed -e "s@{message}@$codestyle_url\\\\\\\n$(echo "$line" | awk -F'!!!!' '{print $3}')@" \
                           -e "s@{line}@$(echo "$line" | awk -F'!!!!' '{print $2}')@" \
                           -e "s@{file}@$f@"
  done
done
