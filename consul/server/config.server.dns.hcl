dns_config {
  allow_stale = true
  max_stale = "10s"
  node_ttl = "60s"
  service_ttl {
    "*" = "60s"
  }
  enable_truncate = true
  only_passing = false # TODO: maybe set to true check the docs for FYI?
  recursor_strategy = "sequential"
  recursor_timeout = "0.5s"
  disable_compression = false
  use_cache = true
}
