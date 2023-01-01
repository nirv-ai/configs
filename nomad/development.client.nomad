data_dir   = "/tmp/client1"
datacenter = "us_east"
log_level  = "WARN"
name       = "development_nirvai_core_client"
region     = "global"

client {
  enabled          = true
  max_kill_timeout = "10s"
  memory_total_mb  = 2048
  node_class       = "dev"

  gc_interval         = "1m"
  gc_max_allocs       = 50
  cni_path            = "/opt/cni/bin"
  bridge_network_name = "dev_core"

  // servers = ["0.0.0.0:4647"]
  server_join {
    retry_join     = ["0.0.0.0:4647"]
    retry_max      = 0
    retry_interval = "5s"
  }

  meta {
    owner = "core"
  }

  reserved {
    memory = 2048
    disk   = 1024
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

plugin "qemu" {}
plugin "java" {}
plugin "exec" {}

plugin "raw_exec" {
  config {
    enabled = true
  }
}


# @see somewhere on this page https://developer.hashicorp.com/nomad/docs/drivers/docker
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

vault {
  address         = "https://dev.nirv.ai:8200"
  cert_file       = "../../nirvai-core-letsencrypt/dev-nirv-ai/live/dev.nirv.ai/fullchain.pem"
  key_file        = "../../nirvai-core-letsencrypt/dev-nirv-ai/live/dev.nirv.ai/privkey.pem"
  tls_server_name = "dev.nirv.ai"
  tls_skip_verify = false
}
