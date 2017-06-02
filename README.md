# couchdb-docker-service
CouchDB as a docker swarm service


## Set up

Run this on your primary box to initialize the docker swarm manager:

    docker swarm init --advertise-addr <ip-address>

Then use the response to register other nodes in the swarm.

Create the network so that the CouchDB nodes can communicate with each other:

    docker network create \
      --driver overlay \
      --subnet 10.0.9.0/24 \
      --opt encrypted \
      couchdb-network


## Create a service

The following examples assume that you have the directory /home/ubuntu/common on each of the boxes in the swarm. Moreover, /home/ubuntu/common/data is a directory that will be mounted as a volume so that your CouchDB data will be persisted across restarts.

### Example:

    docker service create --replicas 2 --name couchdb --network couchdb-network \
      --hostname="couchdb{{.Task.Slot}}" \
      --mount type=bind,source=/home/ubuntu/common,destination=/common \
      -e COUCHDB_COOKIE="mycookie" \
      -e COUCHDB_USER="admin" \
      -e COUCHDB_PASSWORD="admin" \
      -e COUCHDB_HASHED_PASSWORD="-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10" \
      -e COUCHDB_SECRET="mysecret" \
      -e NODENAME="couchdb{{.Task.Slot}}" \
      -e SERVICE_NAME="{{.Service.Name}}" \
      -e TASK_SLOT="{{.Task.Slot}}" \
      -e COUCHDB_DATA_DIR="/common/data/{{.Service.Name}}{{.Task.Slot}}" \
      -p 5984:5984 \
      redgeoff/couchdb-service

### Example with SSL:

We assume /home/ubuntu/common/sql/mydomain.crt and /home/ubuntu/common/sql/mydomain.key are the certificate and private key for your SSL config.

    docker service create --replicas 2 --name couchdb --network couchdb-network \
      --hostname="couchdb{{.Task.Slot}}" \
      --mount type=bind,source=/home/ubuntu/common,destination=/common \
      -e COUCHDB_COOKIE="mycookie" \
      -e COUCHDB_USER="admin" \
      -e COUCHDB_PASSWORD="admin" \
      -e COUCHDB_HASHED_PASSWORD="-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10" \
      -e COUCHDB_SECRET="mysecret" \
      -e NODENAME="couchdb{{.Task.Slot}}" \
      -e SERVICE_NAME="{{.Service.Name}}" \
      -e TASK_SLOT="{{.Task.Slot}}" \
      -e COUCHDB_DATA_DIR="/common/data/{{.Service.Name}}{{.Task.Slot}}" \
      -e COUCHDB_CERT_FILE="/common/ssl/mydomain.crt" \
      -e COUCHDB_KEY_FILE="/common/ssl/mydomain.key" \
      -e COUCHDB_CACERT_FILE="/common/ssl/mydomain.crt" \
      -p 6984:6984 \
      redgeoff/couchdb-service

### Example with SSL and custom local.ini:

We assume /home/ubuntu/common/etc/local.ini contains any custom config, e.g.

    [chttpd]
    bind_address = any

    [httpd]
    bind_address = any

    [couchdb]
    max_dbs_open=1000

Then run:

    docker service create --replicas 2 --name couchdb --network couchdb-network \
      --hostname="couchdb{{.Task.Slot}}" \
      --mount type=bind,source=/home/ubuntu/common,destination=/common \
      -e COUCHDB_COOKIE="mycookie" \
      -e COUCHDB_USER="admin" \
      -e COUCHDB_PASSWORD="admin" \
      -e COUCHDB_HASHED_PASSWORD="-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10" \
      -e COUCHDB_SECRET="mysecret" \
      -e NODENAME="couchdb{{.Task.Slot}}" \
      -e SERVICE_NAME="{{.Service.Name}}" \
      -e TASK_SLOT="{{.Task.Slot}}" \
      -e COUCHDB_DATA_DIR="/common/data/{{.Service.Name}}{{.Task.Slot}}" \
      -e COUCHDB_CERT_FILE="/common/ssl/mydomain.co.crt" \
      -e COUCHDB_KEY_FILE="/common/ssl/mydomain.co.key" \
      -e COUCHDB_CACERT_FILE="/common/ssl/mydomain.co.crt" \
      -e COUCHDB_LOCAL_INI="/common/etc/local.ini" \
      -p 6984:6984 \
      redgeoff/couchdb-service


## To scale up

    docker service scale couchdb=5


## To scale down

TODO: To scale down, you should spin up a new cluster and replicate all the data from the old cluster to the new cluster and then delete the old cluster. See http://docs.couchdb.org/en/2.0.0/cluster/sharding.html#reshard-no-preshard
