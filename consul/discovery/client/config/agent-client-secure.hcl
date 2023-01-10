data_dir = "/consul/data"
datacenter = "us-east"
domain = "mesh.nirv.ai"
enable_central_service_config = true
enable_script_checks = false
log_level = "DEBUG"
server = false

# TODO
retry_join = [ "${SERVER_NAME}${FQDN_SUFFIX}" ]

ports {
  dns   = 8600
  grpc_tls = 8503
  https = 8501
}
