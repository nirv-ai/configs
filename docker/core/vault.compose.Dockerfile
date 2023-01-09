# syntax=docker/dockerfile:1.4

# @see https://hub.docker.com/_/vault
FROM vault:1.12.2 AS vault_build

# https://github.com/hashicorp/docker-consul/blob/master/0.X/Dockerfile
ARG CONSUL_VERSION=1.14.3
ENV HASHICORP_RELEASES=https://releases.hashicorp.com
RUN addgroup consul && \
    adduser -S -G consul consul
RUN set -eux && \
    apk add --no-cache ca-certificates curl gnupg libcap openssl su-exec iputils jq libc6-compat iptables tzdata && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys C874011F0AB405110D02105534365D9472D7468F && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    apkArch="$(apk --print-arch)" && \
    case "${apkArch}" in \
        aarch64) consulArch='arm64' ;; \
        armhf) consulArch='arm' ;; \
        x86) consulArch='386' ;; \
        x86_64) consulArch='amd64' ;; \
        *) echo >&2 "error: unsupported architecture: ${apkArch} (see ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/)" && exit 1 ;; \
    esac && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${consulArch}.zip && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS && \
    grep consul_${CONSUL_VERSION}_linux_${consulArch}.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /tmp/build consul_${CONSUL_VERSION}_linux_${consulArch}.zip && \
    cp /tmp/build/consul /bin/consul && \
    if [ -f /tmp/build/EULA.txt ]; then mkdir -p /usr/share/doc/consul; mv /tmp/build/EULA.txt /usr/share/doc/consul/EULA.txt; fi && \
    if [ -f /tmp/build/TermsOfEvaluation.txt ]; then mkdir -p /usr/share/doc/consul; mv /tmp/build/TermsOfEvaluation.txt /usr/share/doc/consul/TermsOfEvaluation.txt; fi && \
    cd /tmp && \
    rm -rf /tmp/build && \
    gpgconf --kill all && \
    apk del gnupg openssl && \
    rm -rf /root/.gnupg && \
    consul version
RUN test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    chown -R consul:consul /consul

COPY ./vault.compose.bootstrap.sh .
