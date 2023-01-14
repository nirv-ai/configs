#!/bin/sh

if test -f /opt/consul/consul.compose.bootstrap.sh; then
  echo 'running consul.compose.bootstrap.sh'
  /opt/consul/consul.compose.bootstrap.sh
fi

echo 'booting vault'
echo

vault server -log-level=warn -config=/vault/config
