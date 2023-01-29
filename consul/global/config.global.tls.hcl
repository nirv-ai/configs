# TODO: move file locations to cli for 12factor
tls {
  internal_rpc {
    verify_server_hostname = true
    verify_incoming        = true
    verify_outgoing        = true
  }

  defaults {
    ca_file   = "/run/secrets/consul_ca.pem"
    cert_file = "/run/secrets/consul_server.pem"
    key_file  = "/run/secrets/consul_server_privkey.pem"

    # @see https://discuss.hashicorp.com/t/access-consul-web-interface-with-verify-incoming-true/39121
    # make sure to create a p12 cert via script.ssl.sh create p12
    # and install it in your browser
    verify_incoming = true
    verify_outgoing = true
  }
}

http_config {
  response_headers {
    Access-Control-Allow-Origin = "*"
  }
}
