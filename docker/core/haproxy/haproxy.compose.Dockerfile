# syntax=docker/dockerfile:1.4

FROM haproxytech/haproxy-ubuntu:2.7.1 AS haproxy_build

######################### consul & envoy
## consul
# removed su-exec, iputils
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install --no-install-recommends -y unzip ca-certificates curl gnupg libcap-dev openssl jq libc6 iptables tzdata nano && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

ARG CONSUL_VERSION=1.14.3
ARG CONSUL_GID
ARG CONSUL_UID

ENV HASHICORP_RELEASES=https://releases.hashicorp.com
RUN groupadd -r -g $CONSUL_GID consul && \
    useradd -ms /bin/sh -g consul -u $CONSUL_UID consul
RUN mkdir -p /opt/consul/data && \
    mkdir -p /opt/consul/config && \
    chown -R consul:consul /opt/consul
RUN curl "${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" -Lo /tmp/consul.zip && \
  unzip /tmp/consul.zip -d /usr/bin
RUN test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf
COPY --chown=consul:consul ./consul/consul.compose.bootstrap.sh ./opt/consul

## envoy
ENV ENVOY_VERSION_STRING=1.24.1
RUN curl -L https://func-e.io/install.sh | bash -s -- -b /usr/local/bin && \
    func-e use $ENVOY_VERSION_STRING && \
    cp `func-e which` /usr/local/bin/ && \
    envoy --version

######################### haproxy
RUN \
  mkdir -p -m 2750 /var/lib/haproxy && \
  chmod a-w /var/lib/haproxy

WORKDIR /usr/local/etc/haproxy

COPY --chown=haproxy:haproxy ./haproxy/ .

RUN ln -s /usr/local/etc/haproxy/* /var/lib/haproxy
