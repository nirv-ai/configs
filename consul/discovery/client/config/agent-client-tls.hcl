tls {
  internal_rpc {
    verify_server_hostname = true
  }

  defaults {
    ca_file   = "/run/secrets/consul_ca.pem"
    cert_file = "/run/secrets/consul_server.pem"
    key_file  = "/run/secrets/consul_server_privkey.pem"

    verify_incoming        = true
    verify_outgoing        = true
  }
}

http_config {
  response_headers {
    Access-Control-Allow-Origin = "*"
  }
}
