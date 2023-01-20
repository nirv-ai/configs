tls {
  http = true
  rpc  = true

  # if set to false
  # will only ensure each node is signed by the same CA
  # but ignore the nodes region and role
  verify_server_hostname = true
  # requires http api clients to present a cert signed by the same CA as nomads cert
  # enabling prevents consul https health checks for agents
  verify_https_client = false
}
