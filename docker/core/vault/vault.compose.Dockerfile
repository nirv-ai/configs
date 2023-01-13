# syntax=docker/dockerfile:1.4

# @see https://hub.docker.com/_/vault
FROM vault:1.12.2 AS vault_build

######################### consul & envoy
## consul
# @see https://github.com/hashicorp/docker-consul/blob/master/0.X/Dockerfile
ARG CONSUL_VERSION=1.14.3
ARG CONSUL_GID
ARG CONSUL_UID

ENV HASHICORP_RELEASES=https://releases.hashicorp.com
RUN addgroup --gid $CONSUL_GID consul && \
    adduser -D -G consul -u $CONSUL_UID -s /bin/sh consul
RUN set -eux && \
    apk update && apk upgrade && \
    apk add --no-cache ca-certificates bash build-base curl gnupg libcap openssl su-exec iputils jq iptables tzdata && \
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
    consul version
RUN test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    chown -R consul:consul /consul
COPY --chown=consul:consul ./consul/consul.compose.bootstrap.sh ./consul
## envoy
# @see https://hub.docker.com/layers/envoyproxy/envoy-alpine/v1.21-latest/images/sha256-c959cb1484133cd978079d2696b4d903ba489e794db80f0f36469cb5e93ba468?context=explore
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" &&     ALPINE_GLIBC_PACKAGE_VERSION="2.33-r0" &&     ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" &&     ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" &&     ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" &&     apk add --no-cache --virtual=.build-dependencies wget ca-certificates &&     echo         "-----BEGIN PUBLIC KEY-----        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m        1QIDAQAB        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" &&     wget         "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME"         "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME"         "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" &&     apk add --no-cache         "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME"         "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME"         "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" &&         rm "/etc/apk/keys/sgerrand.rsa.pub" &&     /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true &&     echo "export LANG=$LANG" > /etc/profile.d/locale.sh &&         apk del glibc-i18n &&         rm "/root/.wget-hsts" &&     apk del .build-dependencies &&     rm         "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME"         "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME"         "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"
ENV ENVOY_VERSION_STRING=1.24.1
RUN curl -L https://func-e.io/install.sh | bash -s -- -b /usr/local/bin && \
    func-e use $ENVOY_VERSION_STRING && \
    cp `func-e which` /usr/local/bin/ && \
    envoy --version


######################### vault
# @see https://github.com/hashicorp/docker-vault/blob/master/0.X/Dockerfile
# all the dirs are already created
WORKDIR /vault
# FYI: you shown chown -R $USER:$USER this dir on host
COPY --chown=vault:vault ./vault/vault.compose.bootstrap.sh .
