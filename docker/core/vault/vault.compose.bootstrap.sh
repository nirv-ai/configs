#!/bin/sh

CONSUL_BOOTSTRAP_FILE=${CONSUL_DIR_BASE}/consul.compose.bootstrap.sh
if test -f $CONSUL_BOOTSTRAP_FILE; then
  echo "running $CONSUL_BOOTSTRAP_FILE"
  su -p consul sh -c "$CONSUL_BOOTSTRAP_FILE"
fi

echo 'booting vault'
echo

vault server -log-level=warn -config=/vault/config
