data_dir = "/consul/data"
enable_local_script_checks = true
enable_script_checks = false
log_level = "INFO"

addresses {
  https = "0.0.0.0"
}

connect {
  enabled = true
}

ports {
  dns   = 8600
  grpc_tls = 8503
  https = 8501
}

recursors = ["1.1.1.1"]
