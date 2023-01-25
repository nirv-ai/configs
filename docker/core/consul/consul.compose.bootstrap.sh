#!/bin/sh

# @see https://github.com/hashicorp/docker-consul/blob/master/0.X/docker-entrypoint.sh

# uncomment to prevent unhealthy checks and allow you to ssh in and debug
# sleep 3650d

# let the server start without checking for tokens
# as we may be bootstrapping a greenfield server
cat <<-EOF >/consul/config/env.token.hcl
    acl {
      tokens {
        agent  = "$CONSUL_HTTP_TOKEN"
        default  = "$CONSUL_DNS_TOKEN"
      }
    }
EOF

chown -R consul:consul /consul

start_consul() {
  consul agent \
    -config-dir=/consul/config \
    -data-dir=/consul/data \
    -domain=${MESH_HOSTNAME} \
    -node=$CONSUL_NODE_PREFIX-$(hostname)
}

start_consul
