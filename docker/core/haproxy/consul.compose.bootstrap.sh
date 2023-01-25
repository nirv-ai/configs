#!/bin/sh

# uncomment to prevent unhealthy checks and allow you to ssh in and debug
# sleep 3650d

if test -z $CONSUL_HTTP_TOKEN; then
  echo 'EXITING: CONSUL_HTTP_TOKEN not set'
  return 1
fi

cat <<-EOF >/consul/config/env.token.hcl
  acl {
    tokens {
      agent  = "$CONSUL_HTTP_TOKEN"
      default  = "$CONSUL_HTTP_TOKEN"
    }
  }
EOF

chown -R consul:consul /consul
export CONNECT_SIDECAR_FOR=$CONSUL_NODE_PREFIX-$(hostname)

start_envoy() {
  su -g consul - consul sh -c \
    "cd /consul/envoy && envoy -c envoy.yaml"
}

echo "starting envoy service: $CONNECT_SIDECAR_FOR"
start_envoy &

if test -n "$!"; then
  echo $! >/consul/pid.envoy
  echo "envoy started: pid $!"
else
  echo 'error starting envoy'
fi

start_consul() {
  su -g consul - consul sh -c \
    "consul agent -node=${CONNECT_SIDECAR_FOR} -config-dir=/consul/config -data-dir=/consul/data"
}

echo "starting consul agent: $CONNECT_SIDECAR_FOR"
start_consul &

if test -f "/consul/pid.consul"; then
  echo "consul pid saved: : $(cat /consul/pid.consul)"
else
  echo 'consul failed to create pidfile'
fi
