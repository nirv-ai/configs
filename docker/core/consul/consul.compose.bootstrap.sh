#!/bin/sh

# @see https://github.com/hashicorp/docker-consul/blob/master/0.X/docker-entrypoint.sh
# sleep 3650d

if test -n $CONSUL_HTTP_TOKEN; then
  cat <<-EOF >/opt/consul/config/env.token.hcl
    acl {
      tokens {
        agent  = "$CONSUL_HTTP_TOKEN"
        default  = "$CONSUL_DNS_TOKEN"
      }
    }
EOF
fi
consul agent -node=consul -domain=${MESH_HOSTNAME} -config-dir=/opt/consul/config
