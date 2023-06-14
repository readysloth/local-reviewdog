#!/usr/bin/env bash


find_git_changed_files() {
  GIT_CHANGED_FILES=git-changed-files.sh

  TRY_PATH="$(dirname "$0")/utils/$GIT_CHANGED_FILES"
  [ -z "$GIT_CHANGED_FILES_LOC" ] && [ -f "$TRY_PATH" ] && GIT_CHANGED_FILES_LOC="$TRY_PATH"
  TRY_PATH="$(dirname "$0")/../utils/$GIT_CHANGED_FILES"
  [ -z "$GIT_CHANGED_FILES_LOC" ] && [ -f "$TRY_PATH" ] && GIT_CHANGED_FILES_LOC="$TRY_PATH"
  [ -z "$GIT_CHANGED_FILES_LOC" ] && GIT_CHANGED_FILES_LOC="$(command -v git-changed-files.sh)"
  [ -z "$GIT_CHANGED_FILES_LOC" ] && echo "Didn't find $GIT_CHANGED_FILES script" && exit 1
  echo "$GIT_CHANGED_FILES_LOC"
}


find_lib() {
  TRY_PATH="$(dirname "$0")/lib"
  [ -d "$TRY_PATH" ] && echo "$TRY_PATH"
  TRY_PATH="$(dirname "$0")/../lib"
  [ -d "$TRY_PATH" ] && echo "$TRY_PATH"
}


get_raw_template() {
  TEMPLATE_RANGE='"range": {"start": {"line": {line}, "column": {column}}}'
  TEMPLATE_LOC="\"location\": {\"path\" : \"{file}\", $TEMPLATE_RANGE}"
  TEMPLATE="{\"message\": \"*{script}:* {message}\", $TEMPLATE_LOC, \"severity\": \"{severity}\"}"
  echo "$TEMPLATE"
}


change_string_entry() {
  entry_name="$1"
  entry_value="$2"
  string="$3"
  echo "$string" | sed "s^{$entry_name}^$entry_value^g"
}


escape_quotes() {
  string="$1"
  echo "$string" | sed 's/"/\\"/g'
}


escape_backslash() {
  string="$1"
  echo "$string" | sed 's:\\:&&:g'
}


create_suggestion() {
  body="$1"
  suggestion_template='\n```suggestion:0+0\n{suggestion_body}\n```'
  concrete_suggestion="$(change_string_entry "suggestion_body" "$body" "$suggestion_template")"
  echo "$(escape_backslash "$concrete_suggestion")"
}
