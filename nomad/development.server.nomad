# @see https://developer.hashicorp.com/nomad/docs/configuration
# @see https://developer.hashicorp.com/nomad/docs/configuration/server
# @see https://developer.hashicorp.com/nomad/docs/drivers/docker
# @see https://developer.hashicorp.com/nomad/tutorials/transport-security/security-enable-tls#configuring-nomad
# @see https://raw.githubusercontent.com/hashicorp/nomad/master/demo/vagrant/server.hcl

data_dir   = "/tmp/server1"
datacenter = "us_east"
log_level  = "WARN"
name       = "development_nirvai_core_server"
region     = "global"

# dont use bind_addr = "0.0.0.0"
# instead always be explicit
addresses {
  http = "0.0.0.0"
  rpc  = "0.0.0.0"
  serf = "0.0.0.0"
}

// advertise {
//   # Defaults to the first private IP address.
//   http = "192.168.0.5"
//   rpc  = "192.168.0.5"
//   serf = "192.168.0.5"
// }

ports {
  http = 4646
  rpc  = 4647
  serf = 4658
}

# @see https://developer.hashicorp.com/nomad/docs/configuration/server
server {
  enabled                 = true
  bootstrap_expect        = 1 # how many server nodes will there be?
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

# Require TLS
tls {
  # enable tls for http and rpc
  http = true
  rpc  = true

  ca_file   = "./tls/nomad-ca.pem"
  cert_file = "./tls/server.pem"
  key_file  = "./tls/server-key.pem"

  # if set to false
  # will only ensure each node is signed by the same CA
  # but ignore the nodes region and role
  verify_server_hostname = true
  # requires http api clients to present a cert signed by the same CA as nomads cert
  # enabling list prevents consul https health checks for agents
  verify_https_client = false
}


ui {
  enabled = true

  vault {
    ui_url = "https://dev.nirv.ai:8200/ui"
    // address = "${var.VAULT_ADDR}"
  }

  // consul {
  //   ui_url = "https://consul.example.com:8500/ui"
  // }"

}

# enable cors
http_api_response_headers {
  Access-Control-Allow-Origin = "*"
}
