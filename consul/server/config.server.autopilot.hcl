# TODO: https://developer.hashicorp.com/consul/docs/agent/config/config-files#autopilot
autopilot {
  cleanup_dead_servers      = true
  last_contact_threshold    = "1s"
  max_trailing_logs         = 500
  min_quorum                = 0
  server_stabilization_time = "30s"
}
