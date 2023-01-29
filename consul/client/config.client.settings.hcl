rejoin_after_leave    = true
retry_interval        = "10s"
retry_max             = 0
server                = false
use_streaming_backend = true

auto_encrypt {
  # TODO: pretty sure this should be true
  # or maybe its false because we provide the cert files?
  tls = false
}
