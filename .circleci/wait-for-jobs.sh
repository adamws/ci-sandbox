#!/bin/bash

get_running_jobs_count() {
  curl --location --request GET "https://circleci.com/api/v2/workflow/$CIRCLE_WORKFLOW_ID/job" \
    --header "Circle-Token: $CCI_TOKEN" | \
    jq -r '.items[]|select(.name != "waiter")|.status' | \
    grep -c "running"
}

wait_for_running_jobs_to_complete() {
  while [[ $(get_running_jobs_count) -gt 0 ]]
  do
    sleep 10
  done
}

wait_for_running_jobs_to_complete
echo "All required jobs have now completed"
