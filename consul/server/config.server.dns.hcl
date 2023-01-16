dns_config {
  allow_stale         = true
  disable_compression = false
  enable_truncate     = true
  max_stale           = "10s"
  node_ttl            = "60s"
  only_passing        = false # TODO: maybe set to true check the docs
  recursor_strategy   = "sequential"
  recursor_timeout    = "0.5s"
  use_cache           = true

  # TODO: fails validation
  // service_ttl {
  //   * = "60s"
  // }
}
