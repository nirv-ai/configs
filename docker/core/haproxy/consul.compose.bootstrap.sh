#!/bin/sh

echo "intiating consul agent"
su -g consul - consul sh -c "consul agent -node=core-proxy -config-dir=/consul/config" &
echo $! >/consul/pid
echo "pid saved"
