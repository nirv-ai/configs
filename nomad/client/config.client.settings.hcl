data_dir   = "/tmp/client1"
datacenter = "us_east"
log_level  = "WARN"
name       = "development_nirvai_web_client"
region     = "global"

client {
  cni_path            = "/opt/cni/bin"
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

  host_volume "dev_web_postgres" {
    path      = "/tmp/client1/data/web_postgres"
    read_only = false
  }

  meta {
    owner = "core"
  }
}
