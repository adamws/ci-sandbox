#!/bin/bash

set -e
#https://federicoterzi.com/blog/solving-github-status-stuck-on-pending-with-circlecis-approvals/
# Note that the CIRCLECI_JOB_NAME should also include the workflow name
CIRCLECI_JOB_NAME="build2"
REPO_NAME="ci-sandbox"
REPO_OWNER="adamws"
# Note: you should also set a valid GitHub token in the GITHUB_ACCESS_TOKEN variable

echo "Patching approval job named: $CIRCLECI_JOB_NAME"

#CIRCLE_SHA1="b583d9fc96683d2881e57477e21a0c8c37426d22"

echo "waiting for status to appear..."

sleep 10
curl --request GET \
  --url "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/statuses/$CIRCLE_SHA1" \
  --header 'Accept: application/vnd.github.v3+json' \
  --header "Authorization: Bearer $GITHUB_ACCESS_TOKEN" > commit-statuses.json

cat commit-statuses.json
cat commit-statuses.json | jq -r '.[].context' > commit-statuses.txt

if grep -q "ci/circleci: $CIRCLECI_JOB_NAME" "commit-statuses.txt"; then
  echo "status appeared, patching the pending state"
  URL=$(cat commit-statuses.json| jq -r --arg name "$CIRCLECI_JOB_NAME" -c 'map(select(.context | contains($name))) | .[].target_url' | head -1)

  echo $URL
  curl --request POST \
    --url "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/statuses/$CIRCLE_SHA1" \
    --header 'Accept: application/vnd.github.v3+json' \
    --header "Authorization: Bearer $GITHUB_ACCESS_TOKEN" \
    --header 'Content-Type: application/json' \
    --data '{
      "state": "success",
      "target_url": "'"$URL"'",
      "description": "Testing status change",
      "context": "ci/circleci: '"$CIRCLECI_JOB_NAME"'"
    }'

  exit 0
fi

