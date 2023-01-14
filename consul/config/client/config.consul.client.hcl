data_dir = "/consul/data"
domain = "mesh.nirv.ai"
enable_central_service_config = true
enable_script_checks = true
log_level = "DEBUG"
server = false

retry_join = [ "core-consul" ]

ports {
  dns   = 8600
  grpc = 8502
  grpc_tls = 8503
  http = 8500
  https = 8501
}
