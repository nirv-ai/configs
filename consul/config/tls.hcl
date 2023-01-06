ca_file   = "/run/secrets/host_private_ca.pem"
cert_file = "/run/secrets/host_cert.pem"
key_file  = "/run/secrets/host_privkey.pem"

verify_incoming        = false
verify_incoming_rpc    = true
verify_outgoing        = true
verify_server_hostname = true

auto_encrypt {
  allow_tls = true
}
