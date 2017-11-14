# Credit: this work is heavily based on https://github.com/apache/couchdb-docker/blob/master/2.0.0/Dockerfile

# We use ubuntu instead of debian:jessie as we want Erlang >= 18 for CouchDB SSL support
FROM ubuntu

MAINTAINER Geoff Cox redgeoff@gmail.com

# Update distro to get recent list of packages
RUN apt-get update -y -qq

# Download runtime dependencies
RUN apt-get --no-install-recommends -y install \
            erlang-nox \
            erlang-reltool \
            libicu55 \
            libmozjs185-1.0 \
            openssl \
            curl

# Update package lists
RUN apt-get update -y -qq

# The certs need to be installed after we have updated the package lists
RUN apt-get --no-install-recommends -y install \
            ca-certificates

# TODO: Installing nodejs adds almost 300 MB to our image! Even the official node image
# (https://hub.docker.com/_/node/) is 666 MB. Is the best solution to eventually rewrite
# docker-discover-tasks in lower level language like c++?
#
# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get install -y nodejs \
  && npm install npm -g

# Assuming the build process stays the same, you should be able to just change value of
# COUCHDB_VERSION to upgrade to the latest source
ENV COUCHDB_VERSION 2.1.1

# Download CouchDB, build it and then clean up
RUN buildDeps=" \
    g++ \
    erlang-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libmozjs185-dev \
    make \
    wget \
  " \
  && apt-get --no-install-recommends -y install $buildDeps \
  && cd /usr/src \
  && wget http://www-us.apache.org/dist/couchdb/source/$COUCHDB_VERSION/apache-couchdb-$COUCHDB_VERSION.tar.gz \
  && tar xfz apache-couchdb-$COUCHDB_VERSION.tar.gz \
  && rm apache-couchdb-$COUCHDB_VERSION.tar.gz \
  && cd apache-couchdb-$COUCHDB_VERSION \
  && ./configure \
  && make release \
  && adduser --system \
             --shell /bin/bash \
             --group --gecos \
             "CouchDB Administrator" couchdb \
  && mv ./rel/couchdb /home/couchdb \
  && cd ../ \
  && rm -rf apache-couchdb-$COUCHDB_VERSION \
  && apt-get purge -y --auto-remove $buildDeps \
  && rm -rf /var/lib/apt/lists/*

# Add config files
COPY local.ini /home/couchdb/couchdb/etc/local.d/
COPY vm.args /home/couchdb/couchdb/etc/

# Set up directories and permissions
RUN mkdir -p /home/couchdb/couchdb/data /home/couchdb/couchdb/etc/default.d \
  && find /home/couchdb/couchdb -type d -exec chmod 0770 {} \; \
  && chmod 0644 /home/couchdb/couchdb/etc/* \
  && chmod 775 /home/couchdb/couchdb/etc/*.d \
  && chown -R couchdb:couchdb /home/couchdb/couchdb/

# docker-discover-tasks allows the nodes to discover each other
RUN npm install -g docker-discover-tasks

WORKDIR /home/couchdb/couchdb

EXPOSE 5984 6984 4369 9100-9200

COPY couchdb-process.sh /couchdb-process.sh
COPY discover-process.sh /discover-process.sh
COPY set-up-process.sh /set-up-process.sh
COPY wait-for-host.sh /wait-for-host.sh
COPY wait-for-it.sh /wait-for-it.sh
COPY wrapper.sh /wrapper.sh

CMD ["/wrapper.sh"]
