tls {
  internal_rpc {
    verify_server_hostname = true
  }

  defaults {
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
