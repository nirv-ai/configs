data_dir   = "/tmp/server1"
datacenter = "us_east"
log_level  = "WARN"
name       = "development_nirvai_core_server"
region     = "global"

addresses {
  http = "0.0.0.0"
  rpc  = "0.0.0.0"
  serf = "0.0.0.0"
}

ports {
  http = 4646
  rpc  = 4647
  serf = 4658
}

server {
  enabled                 = true
  bootstrap_expect        = 1
  node_gc_threshold       = "10m"
  job_gc_interval         = "10m"
  eval_gc_threshold       = "10m"
  deployment_gc_threshold = "10m"
  csi_plugin_gc_threshold = "10m"
  heartbeat_grace         = "30m" # increase to 1hr if changing TLS related stuff on clients
  # @see https://developer.hashicorp.com/nomad/tutorials/transport-security/security-gossip-encryption
  # @see https://www.serf.io/docs/internals/gossip.html
  encrypt = "Dr0cVpi69799XpXDngBs9ZrEO1D43dU8F0ebELAtV6U="

  plan_rejection_tracker {
    enabled        = true
    node_threshold = 5 # increase this value if too many false positives
    node_window    = "10m"
  }
}

tls {
  http = true
  rpc  = true

  ca_file                = "./tls/nomad-ca.pem"
  cert_file              = "./tls/server.pem"
  key_file               = "./tls/server-key.pem"
  verify_server_hostname = true
  verify_https_client    = false
}

vault {
  address               = "https://dev.nirv.ai:8200"
  allow_unauthenticated = true
  cert_file             = "../../nirvai-core-letsencrypt/dev-nirv-ai/live/dev.nirv.ai/fullchain.pem"
  create_from_role      = "periodic_infra"
  enabled               = true
  key_file              = "../../nirvai-core-letsencrypt/dev-nirv-ai/live/dev.nirv.ai/privkey.pem"
  tls_server_name       = "dev.nirv.ai"
  tls_skip_verify       = false
  # TODO: set this value via a variable thats not VAULT_TOKEN
  token                 = "supa-dupa-fly"
}


ui {
  enabled = true

  vault {
    ui_url = "https://dev.nirv.ai:8200/ui"
  }

  // consul {
  //   ui_url = "https://consul.example.com:8500/ui"
  // }"

}

http_api_response_headers {
  Access-Control-Allow-Origin = "*"
}
