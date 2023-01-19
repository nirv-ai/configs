#!/bin/sh

# uncomment to prevent unhealthy checks and allow you to ssh in and debug
# sleep 3650d

if test -z $CONSUL_HTTP_TOKEN; then
  echo 'EXITING: CONSUL_HTTP_TOKEN not set'
  return 1
fi

cat <<-EOF >/opt/consul/config/env.token.hcl
  acl {
    tokens {
      agent  = "$CONSUL_HTTP_TOKEN"
      default  = "$CONSUL_HTTP_TOKEN"
    }
  }
EOF

chown -R consul:consul /opt/consul
export CONNECT_SIDECAR_FOR=$CONSUL_NODE_PREFIX-$(hostname)

start_envoy() {
  su -g consul - consul sh -c \
    "cd /opt/consul/envoy && envoy -c envoy.yaml"
}

echo "starting envoy service: $CONNECT_SIDECAR_FOR"
start_envoy &

if test -n "$!"; then
  echo $! >/opt/consul/pid.envoy
  echo "envoy started: pid $!"
else
  echo 'error starting envoy'
fi

start_consul() {
  su -g consul - consul sh -c \
    "consul agent -node=${CONNECT_SIDECAR_FOR} -config-dir=/opt/consul/config -data-dir=/opt/consul/data"
}

echo "starting consul agent: $CONNECT_SIDECAR_FOR"
start_consul &

if test -f "/opt/consul/pid.consul"; then
  echo "consul pid saved: : $(cat /opt/consul/pid.consul)"
else
  echo 'consul failed to create pidfile'
fi
