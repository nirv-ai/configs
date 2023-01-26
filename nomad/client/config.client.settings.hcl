client {
  cni_path            = "/opt/cni/bin"
  cni_config_dir = "/opt/cni/config"
  enabled          = true
  gc_interval         = "1m"
  gc_max_allocs       = 50
  max_kill_timeout = "10s"
  memory_total_mb  = 2048
  node_class = "dev"

  server_join {
    retry_join     = ["0.0.0.0:4647"]
    retry_max      = 0
    retry_interval = "5s"
  }

  meta {
    owner = "core"
  }
}
