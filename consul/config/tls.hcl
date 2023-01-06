tls {
  internal_rpc {
    verify_server_hostname = true
  }

  defaults {
    ca_file   = "/run/secrets/mesh_ca_cert.pem"
    cert_file = "/run/secrets/mesh_server_0_cert.pem"
    key_file  = "/run/secrets/mesh_server_0_privkey.pem"

    verify_incoming        = false
    verify_outgoing        = true
  }
}

auto_encrypt {
  allow_tls = true
}
