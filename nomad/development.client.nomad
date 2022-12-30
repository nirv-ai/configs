data_dir   = "/tmp/client1"
datacenter = "us_east"
log_level  = "WARN"
name       = "development_nirvai_core_client"
region     = "global"

# this should be like "nomad.service.consul:4647" and a system
# like Consul used for service discovery.
# @see https://developer.hashicorp.com/nomad/docs/configuration/client
client {
  enabled = true

  server_join {
    retry_join = ["0.0.0.0:4647"]
  }
}

ports {
  http = 5656
}

tls {
  http = true
  rpc  = true

  ca_file   = "./tls/nomad-ca.pem"
  cert_file = "./tls/client.pem"
  key_file  = "./tls/client-key.pem"

  # if set to false
  # will only ensure each node is signed by the same CA
  # but ignore the nodes region and role
  verify_server_hostname = true
  # requires http api clients to present a cert signed by the same CA as nomads cert
  # enabling list prevents consul https health checks for agents
  verify_https_client = false
}


plugin "raw_exec" {
  config {
    enabled = true
  }
}

plugin "exec" {
  config {}
}

plugin "docker" {
  config {
    endpoint = "unix:///var/run/docker.sock"

    extra_labels = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]

    gc {
      image       = true
      image_delay = "3m"
      container   = true

      dangling_containers {
        enabled        = true
        dry_run        = false
        period         = "5m"
        creation_grace = "5m"
      }
    }

    volumes {
      enabled      = true
      selinuxlabel = "z"
    }

    allow_privileged = false
    allow_caps = ["audit_write", "chown", "dac_override", "fowner", "fsetid", "kill", "mknod",
    "net_bind_service", "setfcap", "setgid", "setpcap", "setuid", "sys_chroot", "ipc_lock"]
  }
}
