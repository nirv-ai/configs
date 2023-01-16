Kind     = "service-defaults"
Name     = "core-vault"
Protocol = "http"

UpstreamConfig {
  Defaults {
    Limits {
      MaxConcurrentRequests = 512
      MaxConnections        = 512
      MaxPendingRequests    = 512
    }
  }
}
