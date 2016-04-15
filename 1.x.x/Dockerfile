FROM debian:jessie

# Heavily based on the build from Clemens Stolle <klaemo@fastmail.fm>
# with a custom build of libmozjs with a patch to make it work with
# a grsecurity kernel. This lets the couchdb pass the installation verification
# in Futon (/_utils/veriy_install.html).

MAINTAINER Samuel Tardieu <sam@rfc1149.net>

# Install instructions from https://cwiki.apache.org/confluence/display/COUCHDB/Debian

ENV COUCHDB_VERSION 1.x.x

RUN groupadd -r couchdb && useradd -d /usr/local/var/lib/couchdb -g couchdb couchdb

# download dependencies, compile and install couchdb
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl libtool autoconf automake autoconf-archive pkg-config \
    libnspr4 libnspr4-0d libnspr4-dev libcurl4-openssl-dev libicu-dev zip python git libicu52 \
  && curl -ssL https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb -o esl.deb && dpkg -i esl.deb && apt-get update \
  && apt-get install -y --no-install-recommends erlang-nox erlang-dev \
  && (curl http://tomobox.fr/js185-1.0.0.tar.gz | tar zxf -) \
  && (cd js-1.8.5 && curl http://tomobox.fr/libmozjs185-grsec.patch | patch -p1 && cd js/src && ./configure --prefix=/usr && make && make install) \
  && mkdir -p /usr/src

RUN cd /usr/src \
  && git clone --single-branch --branch 1.x.x https://github.com/apache/couchdb \
  && cd couchdb \
  && ./bootstrap \
  && ./configure --with-js-lib=/usr/lib --with-js-include=/usr/include/mozjs \
  && make && make install \
  && apt-get purge -y perl binutils cpp make build-essential libnspr4-dev libcurl4-openssl-dev libicu-dev python libtool autoconf automake autoconf-archive pkg-config git \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* /usr/src/couchdb /esl.deb /js-1.8.5

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

# permissions
RUN chown -R couchdb:couchdb \
    /usr/local/lib/couchdb /usr/local/etc/couchdb \
    /usr/local/var/lib/couchdb /usr/local/var/log/couchdb /usr/local/var/run/couchdb \
  && chmod -R g+rw \
    /usr/local/lib/couchdb /usr/local/etc/couchdb \
    /usr/local/var/lib/couchdb /usr/local/var/log/couchdb /usr/local/var/run/couchdb

# Expose to the outside
ADD global-bind-address.ini /usr/local/etc/couchdb/default.d/

COPY ./docker-entrypoint.sh /entrypoint.sh

# Define mountable directories.
VOLUME ["/usr/local/var/log/couchdb", "/usr/local/var/lib/couchdb"]

EXPOSE 5984
WORKDIR /usr/local/var/lib/couchdb

ENTRYPOINT ["/entrypoint.sh"]
CMD ["couchdb"]
