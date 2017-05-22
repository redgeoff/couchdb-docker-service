#!/bin/bash

# Adaptation of https://docs.docker.com/engine/admin/multi-service_container/

# Start the discover process
/discover-process.sh &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start discover-process: $status"
  exit $status
fi

# Start the couchdb process
/couchdb-process.sh &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start couchdb-process: $status"
  exit $status
fi

# Start the set-up process in the foreground after the couchdb1 is ready. We expect this process to
# complete and then the script will continue on and monitor the other 2 processes.
/wait-for-it.sh couchdb1:5984 -t 300 -- /set-up-process.sh

# Naive check runs checks once a minute to see if either of the processes exited. The container will
# exit with an error

while /bin/true; do
  DISCOVER_STATUS=$(ps aux | grep discover-process | grep -v grep | wc -l)
  COUCHDB_STATUS=$(ps aux | grep couchdb-process | grep -v grep | wc -l)

  # If the greps above find anything, they will exit with 0 status
  # If they are not both 0, then something is wrong

  if [ $DISCOVER_STATUS -ne 1 ]; then
    echo "discover-process has exited."
    exit -1
  fi

  if [ $COUCHDB_STATUS -ne 1 ]; then
    echo "couchdb-processes has exited."
    exit -1
  fi

  sleep 30
done
