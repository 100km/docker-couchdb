#!/bin/bash
set -e

if [ "$1" = 'couchdb' ]; then
  # We need to set the permissions here because docker mounts volumes as root.
  # We also ignore errors in chown/chmod as it might be possible that the
  # container is used with FAT filesystems.
  chown -R couchdb:couchdb \
    /usr/local/var/lib/couchdb \
    /usr/local/var/log/couchdb \
    /usr/local/var/run/couchdb \
    /usr/local/etc/couchdb || true

  chmod -R 0770 \
    /usr/local/var/lib/couchdb \
    /usr/local/var/log/couchdb \
    /usr/local/var/run/couchdb \
    /usr/local/etc/couchdb || true

  chmod 664 /usr/local/etc/couchdb/*.ini || true
  chmod 775 /usr/local/etc/couchdb/*.d || true
  HOME=/usr/local/var/lib/couchdb exec gosu couchdb "$@"
fi

exec "$@"
