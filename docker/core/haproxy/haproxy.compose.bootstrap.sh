#!/bin/sh

CONSUL_BOOTSTRAP_FILE=${CONSUL_DIR_BASE}/consul.compose.bootstrap.sh
if test -f $CONSUL_BOOTSTRAP_FILE; then
  echo "running $CONSUL_BOOTSTRAP_FILE"
  su -pg consul consul sh -c "$CONSUL_BOOTSTRAP_FILE"
fi

echo 'starting haproxy'

/docker-entrypoint.sh haproxy -f /var/lib/haproxy/configs
