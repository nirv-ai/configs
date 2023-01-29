# TODO: move to cli for 12factor
ports {
  dns              = 8600
  expose_max_port  = 0
  expose_min_port  = 0
  grpc             = -1 # force tls
  grpc_tls         = 8503
  http             = -1 # force tls
  https            = 8501
  serf_lan         = 8301
  serf_wan         = 8302
  server           = 8300
  sidecar_max_port = 21255
  sidecar_min_port = 21000
}
