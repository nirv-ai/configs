rejoin_after_leave    = false
retry_interval        = "10s"
retry_max             = 0
use_streaming_backend = true

auto_encrypt {
  # TODO: pretty sure this should be true
  # or maybe its false because we provide the cert files?
  tls = false
}
