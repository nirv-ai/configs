rejoin_after_leave    = true
retry_interval        = "10s"
retry_max             = 0
server                = false
use_streaming_backend = true

# this needs to match the docker service name
retry_join = ["core-consul"]

auto_encrypt {
  tls = false
}
