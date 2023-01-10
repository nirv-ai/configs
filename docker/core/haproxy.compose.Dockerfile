# syntax=docker/dockerfile:1.4

FROM haproxytech/haproxy-ubuntu:2.7.1 AS haproxy_build

######################### consul
# removed su-exec, iputils
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y unzip ca-certificates curl gnupg libcap-dev openssl jq libc6 iptables tzdata nano

ARG CONSUL_VERSION=1.14.3
ENV HASHICORP_RELEASES=https://releases.hashicorp.com
RUN groupadd -r -g 1001 consul && \
    useradd -ms /bin/sh -g consul -u 1001 consul
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    chown -R consul:consul /consul
RUN curl "${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" -Lo /tmp/consul.zip && \
  unzip /tmp/consul.zip -d /usr/bin
RUN test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf
COPY --chown=consul:consul ./consul/consul.compose.bootstrap.sh ./consul

######################### haproxy
RUN \
  mkdir -p -m 2750 /var/lib/haproxy && \
  chmod a-w /var/lib/haproxy

WORKDIR /usr/local/etc/haproxy

COPY --chown=haproxy:haproxy ./haproxy/ .

RUN ln -s /usr/local/etc/haproxy/* /var/lib/haproxy
