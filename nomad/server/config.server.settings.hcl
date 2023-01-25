server {
  csi_plugin_gc_threshold = "10m"
  deployment_gc_threshold = "10m"
  enabled                 = true
  eval_gc_threshold       = "10m"
  heartbeat_grace         = "30m" # increase to 1hr if changing TLS related stuff on clients
  job_gc_interval         = "10m"
  node_gc_threshold       = "10m"
  raft_protocol = 3 # 3> required for autopilot

  plan_rejection_tracker {
    enabled        = true
    node_threshold = 5 # increase this value if too many false positives
    node_window    = "10m"
  }

  search {
    fuzzy_enabled   = true
    limit_query     = 200
    limit_results   = 1000
    min_term_length = 5
  }
}
