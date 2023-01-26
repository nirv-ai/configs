# syntax=docker/dockerfile:1.4

FROM consul:1.14.3 AS consul_build

ARG CONSUL_GID
ARG CONSUL_UID

RUN \
  grep -qE "^consul:" ./etc/passwd && \
  sed -i "s/^consul:.*:[0-9]\{1,\}:[0-9]\{1,\}:/consul:x:$CONSUL_UID:$CONSUL_GID:/i" /etc/passwd && \
  sed -i "s/^consul:.*:[0-9]\{1,\}:/consul:x:$CONSUL_GID:/i" /etc/group

RUN \
  mkdir -p /consul/data && \
  mkdir -p /consul/config && \
  chown -R $CONSUL_UID:$CONSUL_GID /consul

WORKDIR /consul

COPY --chown=$CONSUL_UID:$CONSUL_GID ./consul.compose.bootstrap.sh .

USER consul
