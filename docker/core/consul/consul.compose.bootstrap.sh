#!/bin/sh

# @see https://github.com/hashicorp/docker-consul/blob/master/0.X/docker-entrypoint.sh

# uncomment to prevent unhealthy checks and allow you to ssh in and debug
# sleep 3650d

CBD=${CONSUL_DIR_BASE}          # consul base dir
CCD=${CBD}/${CONSUL_DIR_CONFIG} # consul config dir
CDD=${CBD}/${CONSUL_DIR_DATA}   # consul data dir

# re-export things
# we renamed them for sorting alphabetically
export CONSUL_HTTP_ADDR=https://${MESH_HOSTNAME}:${CONSUL_PORT_CUNT}
export CONSUL_TLS_SERVER_NAME=${MESH_SERVER_HOSTNAME}
export CONSUL_FQDN_ADDR=${MESH_HOSTNAME}

# let the server start without checking for tokens
# as we may be bootstrapping a greenfield server
# we set auto-reload-config to true so DO NOT remove this
cat <<-EOF >${CCD}/env.token.hcl
  acl {
    tokens {
      agent  = "$CONSUL_HTTP_TOKEN"
      default  = "$CONSUL_DNS_TOKEN"
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

start_consul() {
  # check the docs for additional options
  # TODO: these need additional logic in place
  # -encrypt=CONSUL_ENCRYPT_KEY # i think this is set in .env.auto
  # ensure -ui is only set on server with index 0 or something

  # start the server agent
  consul agent \
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
    -serf-lan-bind=${CONSUL_ADDR_BIND_LAN} \
    -serf-lan-port=${CONSUL_PORT_SERF_LAN} \
    -serf-wan-bind=${CONSUL_ADDR_BIND_WAN} \
    -serf-wan-port=${CONSUL_PORT_SERF_WAN} \
    -server \
    -server-port=${CONSUL_PORT_SERVER} \
    -ui
}

start_consul
