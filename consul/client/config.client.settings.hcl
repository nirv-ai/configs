rejoin_after_leave    = true
retry_interval        = "10s"
retry_max             = 0
server                = false
use_streaming_backend = true

retry_join = ["core-consul"] # TODO nomad should set this to an ip
