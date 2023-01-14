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

# FYI: alpine doesnt have su -g groupname, so we just set user
echo "intiating consul agent"
su - consul sh -c "consul agent -node=core-vault -config-dir=/opt/consul/config" &
echo "consul success?: $?"
echo "consul pid saved: : $(cat /opt/consul/pid.consul)"

# FYI: alpine doesnt have su -g groupname, so we just set user
echo "starting envoy service"
su - consul sh -c "cd /opt/consul/envoy && envoy -c envoy.yaml" &
echo "envoy success?: $?"
echo $! >/opt/consul/pid.envoy
echo "envoy pid saved: $(cat /opt/consul/pid.envoy)"
