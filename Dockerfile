FROM debian:jessie

# Update distro
RUN apt-get update -y && apt-get -y upgrade && apt-get -y dist-upgrade

# Install CouchDB from source
RUN apt-get --no-install-recommends -y install \
            build-essential pkg-config erlang \
            libicu-dev libmozjs185-dev libcurl4-openssl-dev \
            wget curl ca-certificates \
  && cd /usr/src \
  && wget http://www-eu.apache.org/dist/couchdb/source/2.0.0/apache-couchdb-2.0.0.tar.gz \
  && tar xfz apache-couchdb-2.0.0.tar.gz \
  && cd apache-couchdb-2.0.0 \
  && ./configure \
  && make release \
  && adduser --system \
             --shell /bin/bash \
             --group --gecos \
             "CouchDB Administrator" couchdb \
  && cp -R ./rel/couchdb /home/couchdb \
  && chown -R couchdb:couchdb /home/couchdb/couchdb \
  && find /home/couchdb/couchdb -type d -exec chmod 0770 {} \; \
  && chmod 0644 /home/couchdb/couchdb/etc/*

# grab gosu for easy step-down from root and tini for signal handling
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
  && curl -o /usr/local/bin/tini -fSL "https://github.com/krallin/tini/releases/download/v0.14.0/tini" \
  && curl -o /usr/local/bin/tini.asc -fSL "https://github.com/krallin/tini/releases/download/v0.14.0/tini.asc" \
  && gpg --verify /usr/local/bin/tini.asc \
  && rm /usr/local/bin/tini.asc \
  && chmod +x /usr/local/bin/tini

# Add config files
COPY local.ini /home/couchdb/couchdb/etc/local.d/
COPY vm.args /home/couchdb/couchdb/etc/

COPY ./docker-entrypoint.sh /

# Setup directories and permissions
RUN mkdir /home/couchdb/couchdb/data /home/couchdb/couchdb/etc/default.d \
  && chown -R couchdb:couchdb /home/couchdb/couchdb/

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
  && apt-get install -y nodejs \
  && npm install npm -g

# docker-discover-tasks helps the nodes discover each other
RUN npm install -g docker-discover-tasks

WORKDIR /home/couchdb/couchdb

EXPOSE 5984 4369 9100-9200

VOLUME ["/home/couchdb/couchdb/data"]

COPY couchdb-process.sh /couchdb-process.sh
COPY discover-process.sh /discover-process.sh
COPY set-up-process.sh /set-up-process.sh
COPY wait-for-it.sh /wait-for-it.sh
COPY wrapper.sh /wrapper.sh

CMD ["/wrapper.sh"]
