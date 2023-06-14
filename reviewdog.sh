#!/usr/bin/env bash

set -e

[ -z "$GITLAB_TOKEN" ] && echo 'You must set $GITLAB_TOKEN' && exit 1
[ -z "$REPO_GROUP" ] && echo 'You must set $REPO_GROUP' && exit 1
[ -z "$REPO_NAME" ] && echo 'You must set $REPO_NAME' && exit 1
[ -z "$GITLAB_DOMAIN" ] && echo 'You must set $GITLAB_DOMAIN' && exit 1

export REVIEWDOG_GITLAB_API_TOKEN="${GITLAB_TOKEN}"
export GITLAB_API=http://${GITLAB_DOMAIN}/api/v4
export REVIEWDOG_INSECURE_SKIP_VERIFY=true

export CI_REPO_OWNER="${REPO_GROUP}"
export CI_REPO_NAME="${REPO_NAME}"
export CI_COMMIT="$(git rev-parse @)"
REVIEWDOG="$(dirname "$(command -v "$0")")/bin/reviewdog"
[ ! -f "$REVIEWDOG" ] && REVIEWDOG=reviewdog

if [ -z "$MR_BRANCH" ]
then
  exec "$REVIEWDOG" \
    -f=rdjsonl \
    -diff="git diff $CI_COMMIT~$1..$CI_COMMIT" \
    -level=info \
    -reporter="${REVIEWDOG_REPORTER:-gitlab-mr-discussion}" \
    -filter-mode="${REVIEWDOG_FILTER_MODE:-diff_context}" \
    -guess \
    -tee
fi

exec "$REVIEWDOG" \
  -f=rdjsonl \
  -diff="git diff $MR_BRANCH" \
  -level=info \
  -reporter="${REVIEWDOG_REPORTER:-gitlab-mr-discussion}" \
  -filter-mode="${REVIEWDOG_FILTER_MODE:-diff_context}" \
  -guess \
  -tee
