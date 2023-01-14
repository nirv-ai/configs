# todo: should be set by nomad
# and appropriate for the env we're deploying to
performance {
  raft_multiplier = 3
  leave_drain_time = "5s"
  rpc_hold_timeout = "4s"
}
