Kind     = "service-defaults"
Name     = "core-proxy"
Protocol = "tcp"
Mode     = "direct"

UpstreamConfig {
  Defaults {
    Limits {
      MaxConcurrentRequests = 512
      MaxConnections        = 512
      MaxPendingRequests    = 512
    }
  }
}
