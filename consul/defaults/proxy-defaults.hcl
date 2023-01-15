Kind = "proxy-defaults"
Name = "global"
Mode = "direct"

Config {
  bind_address             = "0.0.0.0"
  handshake_timeout_ms     = 10000
  local_connect_timeout_ms = 1000
  local_idle_timeout_ms    = 5000
  local_request_timeout_ms = 5000
  max_inbound_connections  = 500
}
Expose {
  checks = true
}
