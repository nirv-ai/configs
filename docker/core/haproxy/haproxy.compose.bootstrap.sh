#!/bin/sh

if test -f /consul/consul.compose.bootstrap.sh; then
  echo 'running consul.compose.bootstrap.sh'
  /consul/consul.compose.bootstrap.sh
fi

echo 'starting haproxy'

/docker-entrypoint.sh haproxy -f /var/lib/haproxy/configs
