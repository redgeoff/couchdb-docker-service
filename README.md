# couchdb-docker-service
CouchDB as a docker swarm service

TODO
---

    docker swarm init --advertise-addr <ip-address>

    docker network create \
      --driver overlay \
      --subnet 10.0.9.0/24 \
      --opt encrypted \
      couchdb-network

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
      -e COUCHDB_CERT_FILE="/common/ssl/mydomain.crt" \
      -e COUCHDB_KEY_FILE="/common/ssl/mydomain.key" \
      -e COUCHDB_CACERT_FILE="/common/ssl/mydomain.crt" \
      -p 6984:6984 \
      redgeoff/couchdb-service

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
      -e COUCHDB_CERT_FILE="/common/ssl/mydomain.co.crt" \
      -e COUCHDB_KEY_FILE="/common/ssl/mydomain.co.key" \
      -e COUCHDB_CACERT_FILE="/common/ssl/mydomain.co.crt" \
      -e COUCHDB_DATA_DIR="/common/data/{{.Service.Name}}{{.Task.Slot}}" \
      -e COUCHDB_LOCAL_INI="/common/etc/local.ini" \
      -p 6984:6984 \
      redgeoff/couchdb-service
