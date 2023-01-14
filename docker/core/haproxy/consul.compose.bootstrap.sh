#!/bin/sh

echo "intiating consul agent"
su -g consul - consul sh -c "consul agent -node=core-proxy -config-dir=/opt/consul/config" &
echo "consul success?: $?"
echo $! >/consul/pid.consul
echo "consul pid saved: : $(cat /consul/pid.consul)"

echo "starting envoy service"
su -g consul - consul sh -c "cd /consul/envoy && envoy -c envoy.yaml" &
echo "envoy success?: $?"
echo $! >/consul/pid.envoy
echo "envoy pid saved: $(cat /consul/pid.envoy)"
