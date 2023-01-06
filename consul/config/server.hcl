data_dir = "/consul/data"
enable_local_script_checks = true
enable_script_checks = false
log_level = "INFO"
recursors = ["1.1.1.1"]

addresses {
  dns = "0.0.0.0"
  grpc = "127.0.0.1"
  https = "0.0.0.0"
}
ports {
  dns   = 8600
  grpc = 8502
  grpc_tls  = 8503
  http  = 8500
  https = 8443
}

connect {
  enabled = true
}
