tls {
  internal_rpc {
    verify_server_hostname = true
  }

  defaults {
    ca_file   = "/run/secrets/consul_ca.pem"

    verify_incoming        = true
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
