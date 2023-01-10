#!/bin/sh

su -g consul - consul sh -c "consul agent -node=core-proxy -config-dir=/consul/config" &
