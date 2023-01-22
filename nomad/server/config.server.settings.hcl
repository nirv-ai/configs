datacenter = "us_east"
log_level  = "WARN"
region     = "global"

server {
  enabled                 = true
  bootstrap_expect        = 1
  node_gc_threshold       = "10m"
  job_gc_interval         = "10m"
  eval_gc_threshold       = "10m"
  deployment_gc_threshold = "10m"
  csi_plugin_gc_threshold = "10m"
  heartbeat_grace         = "30m" # increase to 1hr if changing TLS related stuff on clients

  plan_rejection_tracker {
    enabled        = true
    node_threshold = 5 # increase this value if too many false positives
    node_window    = "10m"
  }
}
