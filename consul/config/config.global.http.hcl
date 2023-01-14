http_config {
  # block_endpoints = [] todo: should be set by nomad
  # allow_write_http_from = [] todo: should be set by nomad
  max_header_bytes = 1000000 # 1mb
  use_cache = true
  response_headers {
    Access-Control-Allow-Origin = "*"
  }
}
