# todo: should be set by nomad
# and should fit the env we're deploying to
{
  http_max_conns_per_client = 200
  https_handshake_timeout = "1s"
  rpc_client_timeout = "60s"
  rpc_handshake_timeout = "1s"
  rpc_max_burst = 1000
  rpc_max_conns_per_client = 25
  rpc_rate = 100
}
