data_dir = "/consul/data"
domain = "mesh.nirv.ai"
enable_central_service_config = true
enable_script_checks = false
log_level = "DEBUG"
server = false

retry_join = [ "172.20.0.2" ]

ports {
  dns   = 8600
  grpc_tls = 8503
  https = 8501
}
