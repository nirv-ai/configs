#!/bin/sh

# sleep 3650d
consul agent -node=consul -domain=${MESH_HOSTNAME} -config-dir=/consul/config
