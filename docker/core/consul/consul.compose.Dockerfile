# syntax=docker/dockerfile:1.4

FROM consul:1.14.3 AS consul_build

ARG CONSUL_GID
ARG CONSUL_UID
ARG CONSUL_DIR_BASE
ARG CONSUL_DIR_CONFIG
ARG CONSUL_DIR_DATA

RUN \
  grep -qE "^consul:" ./etc/passwd && \
  sed -i "s/^consul:.*:[0-9]\{1,\}:[0-9]\{1,\}:/consul:x:$CONSUL_UID:$CONSUL_GID:/i" /etc/passwd && \
  sed -i "s/^consul:.*:[0-9]\{1,\}:/consul:x:$CONSUL_GID:/i" /etc/group

RUN \
  mkdir -p $CONSUL_DIR_BASE/$CONSUL_DIR_CONFIG && \
  mkdir -p $CONSUL_DIR_BASE/$CONSUL_DIR_DATA && \
  chown -R $CONSUL_UID:$CONSUL_GID $CONSUL_DIR_BASE

WORKDIR $CONSUL_DIR_BASE

COPY --chown=$CONSUL_UID:$CONSUL_GID ./consul.compose.bootstrap.sh .

USER consul
