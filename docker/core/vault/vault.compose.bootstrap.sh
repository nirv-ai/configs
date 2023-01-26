#!/bin/sh

if test -f /consul/consul.compose.bootstrap.sh; then
  echo 'running consul.compose.bootstrap.sh'
  /consul/consul.compose.bootstrap.sh
fi

echo 'booting vault'
echo

vault server -log-level=warn -config=/vault/config
