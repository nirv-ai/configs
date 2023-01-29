#!/bin/sh

# FYI: this file should be run as the consul user
# uncomment to prevent unhealthy checks and allow you to ssh in and debug
# sleep 3650d

CBD=${CONSUL_DIR_BASE}          # consul base dir
CCD=${CBD}/${CONSUL_DIR_CONFIG} # consul config dir
CDD=${CBD}/${CONSUL_DIR_DATA}   # consul data dir

# re-export things
# we renamed them for sorting alphabetically
export CONSUL_HTTP_ADDR=https://${MESH_HOSTNAME}:${CONSUL_PORT_CUNT}
export CONSUL_TLS_SERVER_NAME=${MESH_SERVER_HOSTNAME}
export CONNECT_SIDECAR_FOR=$CONSUL_NODE_PREFIX-$(hostname)

# this runs in client mode, not server
# fail if the http_token isnt set
if test -z $CONSUL_HTTP_TOKEN; then
  echo 'EXITING: CONSUL_HTTP_TOKEN not set'
  return 1
fi

# TODO: we still need to create a token specific for envoy
# ^ currently it fallsback to the default token below
cat <<-EOF >${CCD}/env.token.hcl
  acl {
    tokens {
      agent  = "$CONSUL_HTTP_TOKEN"
      default  = "$CONSUL_HTTP_TOKEN"
    }
  }
EOF

# create cert defaults from env vars
cat <<-EOF >${CCD}/env.certs.hcl
  tls {
    defaults {
      ca_file = "${CONSUL_CACERT}"
      cert_file = "${CONSUL_CLIENT_CERT}"
      key_file = "${CONSUL_CLIENT_KEY}"
    }
  }
EOF

start_envoy() {
  cd "${CBD}/envoy" && envoy -c envoy.yaml
}

echo "starting envoy service: $CONNECT_SIDECAR_FOR"
start_envoy &

if test -n "$!"; then
  echo $! >${CBD}/pid.envoy
  echo "envoy started: pid $!"
else
  echo 'error starting envoy'
fi

start_consul() {
  consul agent \
    -node=${CONNECT_SIDECAR_FOR} \
    -advertise='{{ GetInterfaceIP "eth0" }}' \
    -alt-domain=${CONSUL_ALT_DOMAIN} \
    -auto-reload-config \
    -bind=${CONSUL_ADDR_BIND} \
    -client=${CONSUL_ADDR_CLIENT} \
    -config-dir=${CCD} \
    -data-dir=${CDD} \
    -datacenter=${DATACENTER} \
    -dns-port=${CONSUL_PORT_DNS} \
    -domain=${MESH_HOSTNAME} \
    -grpc-port=-1 \
    -grpc-tls-port=${CONSUL_PORT_GRPC} \
    -http-port=-1 \
    -https-port=${CONSUL_PORT_CUNT} \
    -node=${CONSUL_NODE_PREFIX}-$(hostname) \
    -pid-file=${CBD}/${CONSUL_PID_FILE} \
    -retry-join=${CONSUL_SERVER} \
    -serf-lan-bind=${CONSUL_ADDR_BIND_LAN} \
    -serf-lan-port=${CONSUL_PORT_SERF_LAN} \
    -serf-wan-bind=${CONSUL_ADDR_BIND_WAN} \
    -serf-wan-port=${CONSUL_PORT_SERF_WAN} \
    -server-port=${CONSUL_PORT_SERVER}
}

echo "starting consul agent: $CONNECT_SIDECAR_FOR"
start_consul &

if test -f "${CBD}/pid.consul"; then
  echo "consul pid saved: $(cat ${CBD}/pid.consul)"
else
  echo 'consul failed to create pidfile'
fi
