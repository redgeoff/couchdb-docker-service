#!/bin/bash

set -e

if [ "$COUCHDB_DATA_DIR" ]; then
  # Create a symbolic link to the CouchDB data so that we can prefix it with the service name and
  # task slot
  rm -rf /home/couchdb/couchdb/data

  # Make sure directory exists
  mkdir -p $COUCHDB_DATA_DIR

  ln -s $COUCHDB_DATA_DIR /home/couchdb/couchdb/data
fi

# Use sname so that we can specify a short name, like those used by docker, instead of a host
if [ ! -z "$NODENAME" ] && ! grep "couchdb@" /home/couchdb/couchdb/etc/vm.args; then
  # A cookie is needed so that the nodes can connect to each other using Erlang clustering
  if [ -z "$COUCHDB_COOKIE" ]; then
    echo "-sname couchdb@$NODENAME" >> /home/couchdb/couchdb/etc/vm.args
  else
    echo "-sname couchdb@$NODENAME -setcookie '$COUCHDB_COOKIE'" >> /home/couchdb/couchdb/etc/vm.args
  fi
fi

if [ "$COUCHDB_USER" ] && [ "$COUCHDB_PASSWORD" ] && [ -z "$COUCHDB_HASHED_PASSWORD" ]; then
  # Create admin
  printf "[admins]\n%s = %s\n" "$COUCHDB_USER" "$COUCHDB_PASSWORD" >> /home/couchdb/couchdb/etc/local.d/docker.ini
fi

if [ "$COUCHDB_USER" ] && [ "$COUCHDB_HASHED_PASSWORD" ]; then
  # Create the admin using the hashed password. As per https://stackoverflow.com/q/43958527/2831606
  # we need all nodes to have the exact same password hash.
  printf "[admins]\n%s = %s\n" "$COUCHDB_USER" "$COUCHDB_HASHED_PASSWORD" > /home/couchdb/couchdb/etc/local.d/docker.ini
fi

if [ "$COUCHDB_SECRET" ]; then
  # Set secret
  printf "[couch_httpd_auth]\nsecret = %s\n" "$COUCHDB_SECRET" >> /home/couchdb/couchdb/etc/local.d/docker.ini
fi

if [ "$COUCHDB_CERT_FILE" ] && [ "$COUCHDB_KEY_FILE" ] && [ "$COUCHDB_CACERT_FILE" ]; then
  # Enable SSL
  printf "[daemons]\nhttpsd = {chttpd, start_link, [https]}\n\n" >> /home/couchdb/couchdb/etc/local.d/docker.ini
  printf "[ssl]\ncert_file = %s\nkey_file = %s\ncacert_file = %s\n" "$COUCHDB_CERT_FILE" "$COUCHDB_KEY_FILE" "$COUCHDB_CACERT_FILE" >> /home/couchdb/couchdb/etc/local.d/docker.ini

  # As per https://groups.google.com/forum/#!topic/couchdb-user-archive/cBrZ25DHHVA, due to bug
  # https://issues.apache.org/jira/browse/COUCHDB-3162, we need the following lines. TODO: remove
  # this in a later version of CouchDB 2.
  printf "ciphers = undefined\ntls_versions = undefined\nsecure_renegotiate = undefined\n" >> /home/couchdb/couchdb/etc/local.d/docker.ini
fi

# Set the permissions. This is not needed as we are running couchdb as root
# if [ -f /home/couchdb/couchdb/etc/local.d/docker.ini ];
#   chown couchdb:couchdb /home/couchdb/couchdb/etc/local.d/docker.ini
# fi

if [ "$COUCHDB_LOCAL_INI" ]; then
  # If a custom local.ini file is specified, e.g. through a volume, then copy it to CouchDB
  cp $COUCHDB_LOCAL_INI /home/couchdb/couchdb/etc/local.d/local.ini
fi

/home/couchdb/couchdb/bin/couchdb
# /home/couchdb/couchdb/bin/couchdb > /home/couchdb/couchdb/var/log/couch.log 2>&1
