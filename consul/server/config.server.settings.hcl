bootstrap_expect    = 1
discovery_max_stale = "5s"
server              = true

rpc {
  enable_streaming = true
}

# DO NOT uncomment this
# it conflicts with confitg.client.auto_config
# TODO: verify this > auto_config
// auto_encrypt {
//   allow_tls = true
// }
