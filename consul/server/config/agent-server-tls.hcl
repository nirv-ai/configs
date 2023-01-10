tls {
  internal_rpc {
    verify_server_hostname = true
  }

  defaults {
    ca_file   = "/run/secrets/consul_ca.pem"
    cert_file = "/run/secrets/consul_server.pem"
    key_file  = "/run/secrets/consul_server_privkey.pem"

    # TODO:
    # ^ verify_incoming must be set to true to prevent anyone with access
    # ^ to the internal RPC port from gaining full access to the Consul cluster.
    # pretty sure we just need to install & trust the local ca cert in the browser
    verify_incoming        = false  # setting true breaks ui
    verify_outgoing        = true
  }
}

# will auto created client tls certificates
auto_encrypt {
  allow_tls = true
}

http_config {
  response_headers {
    Access-Control-Allow-Origin = "*"
  }
}
