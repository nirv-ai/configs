#!/bin/sh

if test -z $CONSUL_HTTP_TOKEN; then
  echo "CONSUL_HTTP_TOKEN not set; ignoring consul init request"
  return 1
fi

# TODO: need to create token specifically for connect else default is required for envoy
cat <<-EOF >/opt/consul/config/env.token.hcl
  acl {
    tokens {
      agent  = "$CONSUL_HTTP_TOKEN"
      default  = "$CONSUL_HTTP_TOKEN"
    }
  }
EOF

chown -R consul:consul /opt/consul

echo "starting envoy service"
# agent: Check socket connection failed: check=service:core-proxy-1-sidecar-proxy:1 error="dial tcp 127.0.0.1:21000: connect: connection refused"
# su -g consul - consul sh -c "consul connect envoy -sidecar-for core-proxy-1" &
su -g consul - consul sh -c "cd /opt/consul/envoy && envoy -c envoy.yaml" &
echo "envoy success?: $?"
echo $! >/opt/consul/pid.envoy
echo "envoy pid saved: $(cat /opt/consul/pid.envoy)"

echo "starting consul agent"
su -g consul - consul sh -c "consul agent -node=core-proxy -config-dir=/opt/consul/config" &
echo "consul success?: $?"
echo "consul pid saved: : $(cat /opt/consul/pid.consul)"
