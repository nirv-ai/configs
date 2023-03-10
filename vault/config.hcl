# @see https://developer.hashicorp.com/vault/docs/configuration

default_lease_ttl                   = "7d"
default_max_request_duration        = "30s"
disable_cahe                        = false
disable_mlock                       = true # we use integrated raft storage
enable_response_header_hostname     = true
enable_response_header_raft_node_id = true
log_format                          = "json"
max_lease_ttl                       = "30d"
raw_storage_endpoint                = false
ui                                  = true # requires at least 1 listener stanza

storage "raft" {
  path    = "/vault/data"
  node_id = "node1"
}

api_addr     = "https://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"

listener "tcp" {
  address       = "0.0.0.0:8200" # provides access to vault UI
  tls_cert_file = "/run/secrets/host_fullchain.pem"
  tls_key_file  = "/run/secrets/host_privkey.pem"
  tls_disable   = false
}
