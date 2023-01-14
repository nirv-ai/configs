#!/bin/sh

# FYI: alpine doesnt have su -g groupname, so we just set user
echo "intiating consul agent"
su - consul sh -c "consul agent -node=core-vault -config-dir=/consul/config" &
echo "consul success?: $?"
echo $! >/consul/pid.consul
echo "consul pid saved: : $(cat /consul/pid.consul)"

# FYI: alpine doesnt have su -g groupname, so we just set user
echo "starting envoy service"
su - consul sh -c "cd /consul/envoy && envoy -c envoy.yaml" &
echo "envoy success?: $?"
echo $! >/consul/pid.envoy
echo "envoy pid saved: $(cat /consul/pid.envoy)"
