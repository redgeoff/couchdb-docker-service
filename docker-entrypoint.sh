#!/bin/bash

set -e

if [ "$1" = '/home/couchdb/couchdb/bin/couchdb' ]; then

	# Use sname so that we can specify a short name, like those used by docker, instead of a host
	if [ ! -z "$NODENAME" ] && ! grep "couchdb@" /home/couchdb/couchdb/etc/vm.args; then
		# Cookie is needed so that the nodes can connect to each other using Erlang clustering
		if [ -z "$COUCHDB_COOKIE" ]; then
			echo "-sname couchdb@$NODENAME" >> /home/couchdb/couchdb/etc/vm.args
		else
			echo "-sname couchdb@$NODENAME -setcookie '$COUCHDB_COOKIE'" >> /home/couchdb/couchdb/etc/vm.args
		fi
	fi

	if [ "$COUCHDB_USER" ] && [ "$COUCHDB_PASSWORD" ] && [ -z "$COUCHDB_HASHED_PASSWORD" ]; then
		# Create admin
		printf "[admins]\n%s = %s\n" "$COUCHDB_USER" "$COUCHDB_PASSWORD" > /home/couchdb/couchdb/etc/local.d/docker.ini
		chown couchdb:couchdb /home/couchdb/couchdb/etc/local.d/docker.ini
	fi

	if [ "$COUCHDB_USER" ] && [ "$COUCHDB_HASHED_PASSWORD" ]; then
		printf "[admins]\n%s = %s\n" "$COUCHDB_USER" "$COUCHDB_HASHED_PASSWORD" > /home/couchdb/couchdb/etc/local.d/docker.ini
		chown couchdb:couchdb /home/couchdb/couchdb/etc/local.d/docker.ini
	fi

	if [ "$COUCHDB_SECRET" ]; then
		# Set secret
		printf "[couch_httpd_auth]\nsecret = %s\n" "$COUCHDB_SECRET" > /home/couchdb/couchdb/etc/local.d/secret.ini
		chown couchdb:couchdb /home/couchdb/couchdb/etc/local.d/secret.ini
	fi

	exec gosu couchdb "$@"
fi

exec "$@"
