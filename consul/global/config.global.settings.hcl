alt_domain                           = "search"
auto_reload_config                   = true
bind_addr                            = "0.0.0.0"
client_addr                          = "127.0.0.1"
data_dir                             = "/opt/consul/data"
datacenter                           = "us-east"
default_query_time                   = "100s"
disable_http_unprintable_char_filter = false
disable_keyring_file                 = true
disable_remote_exec                  = true
disable_update_check                 = true
discard_check_output                 = true
domain                               = "mesh.nirv.ai"
enable_agent_tls_for_checks          = true
enable_central_service_config        = true
enable_debug                         = false
enable_local_script_checks           = true
enable_script_checks                 = true
encrypt_verify_incoming              = true
encrypt_verify_outgoing              = true
log_level                            = "INFO"
max_query_time                       = "300s"
pid_file                             = "/opt/consul/pid.consul"
primary_datacenter                   = "us-east"
reconnect_timeout                    = "72h"
session_ttl_min                      = "10s"
skip_leave_on_interrupt              = true
translate_wan_addrs                  = true

addresses {
  https = "0.0.0.0"
}
