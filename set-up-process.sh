#!/bin/bash

# The primary node is couchdb1 and is the single node with which all secondary nodes register their
# membership. The primary node and secondary node designation only really matters during the setup
# process and is only used to implement a scalable service architecture.

if [ $TASK_SLOT -eq 1 ]; then
  echo "Setting up primary node..."
  # TODO: check couchdb1:5984/_users to make sure DB doesn't already exist before executing the
  # following

  # Create system databases
  curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_users
  curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_replicator
  curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_global_changes
else
  echo "Setting up secondary node..."

  # Register membership
  curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5986/_nodes/couchdb@couchdb$TASK_SLOT -d {}
fi
