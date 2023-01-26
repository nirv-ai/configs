plugin "raw_exec" {
  config {
    enabled = false
  }
}

plugin "exec" {}



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
