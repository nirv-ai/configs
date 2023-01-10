
# consul acl token create -description "svc-${dc}-${svc} agent token" -node-identity "${ADDR}:${dc}" -service-identity="${svc}"  --format json > ${ASSETS}/acl-token-${ADDR}.json 2> /dev/null
# AGENT_TOK=`cat ${ASSETS}/acl-token-${ADDR}.json | jq -r ".SecretID"`

# Using root token for now: <<<< dont do this
// AGENT_TOKEN=`cat /home/app/assets/acl-token-bootstrap.json | jq -r ".SecretID"`

acl {
  tokens {
    agent  = "STATIC_TOKEN_HERE"
    default  = "STATIC_TOKEN_HERE"
  }
}
